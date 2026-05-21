/*****************************************************************************
 * UpdateAvailableManager.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the LICENSE.md file of the official project for license.
 *****************************************************************************/

import Foundation
import Combine

public struct UpdateAvailableConfiguration {
    public var bundleID: String?
    public var cacheDuration: TimeInterval

    public init(bundleID: String? = nil, cacheDuration: TimeInterval = 3600) {
        self.bundleID = bundleID
        self.cacheDuration = cacheDuration
    }
}

@MainActor
public final class UpdateAvailableManager: ObservableObject {

    public static let shared = UpdateAvailableManager()

    @Published public private(set) var result: UpdateAvailableResult = .noUpdatesAvailable

    private var configuration = UpdateAvailableConfiguration()

    private init() { }

    // MARK: - Public API

    /// Configure UpdateAvailableManager. Call before `start()`.
    public func configure(with configuration: UpdateAvailableConfiguration) {
        self.configuration = configuration
    }

    /// Starts checking for app updates. Call once at app launch.
    public func start() {
        let bundleID = configuration.bundleID ?? Bundle.main.bundleIdentifier ?? ""
        guard !bundleID.isEmpty else { return }
        Task {
            let result = await self.checkForVersionUpdate(
                with: bundleID,
                currentVersion: Bundle.main.releaseVersionNumber
            )
            self.result = result
        }
    }

    /// Checks for an update with a custom current version. For integration testing.
    public func checkForVersionUpdate(
        with bundleID: String,
        currentVersion: String
    ) async -> UpdateAvailableResult {
        if let cached = cachedVersionResult(currentVersion: currentVersion) {
            return cached
        }
        do {
            let response = try await fetchFromITunes(with: bundleID)
            if let version = response.results?.first?.version {
                let result = UpdateAvailableManager.compare(appStoreVersion: version, currentVersion: currentVersion)
                cacheResponse(response)
                return result
            }
            return .noUpdatesAvailable
        } catch {
            return .noUpdatesAvailable
        }
    }

    // MARK: - Private

    private static let cacheKey = "UpdateAvailableManager.ITunesCachedData"

    nonisolated static func compare(appStoreVersion: String, currentVersion: String) -> UpdateAvailableResult {
        let appStoreComponents = appStoreVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }
        let maxCount = max(appStoreComponents.count, currentComponents.count)
        for i in 0..<maxCount {
            let appStoreValue = i < appStoreComponents.count ? appStoreComponents[i] : 0
            let currentValue = i < currentComponents.count ? currentComponents[i] : 0
            if appStoreValue > currentValue {
                return .updateAvailable(newVersion: appStoreVersion)
            } else if appStoreValue < currentValue {
                return .noUpdatesAvailable
            }
        }
        return .noUpdatesAvailable
    }

    private func cachedVersionResult(currentVersion: String) -> UpdateAvailableResult? {
        guard let cachedData = UserDefaults.standard.data(forKey: UpdateAvailableManager.cacheKey),
              let cached = try? JSONDecoder().decode(LookupCachableResponse.self, from: cachedData),
              let version = cached.response.results?.first?.version,
              Date() < cached.expiryDate else {
            return nil
        }
        return UpdateAvailableManager.compare(appStoreVersion: version, currentVersion: currentVersion)
    }

    private func fetchFromITunes(with bundleID: String) async throws -> ITunesLookupResponse {
        guard let url = URL.createITunesLookupURL(with: bundleID) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let response = try? JSONDecoder().decode(ITunesLookupResponse.self, from: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return response
    }

    private func cacheResponse(_ response: ITunesLookupResponse) {
        let cachable = LookupCachableResponse(
            expiryDate: Date().addingTimeInterval(configuration.cacheDuration),
            response: response
        )
        guard let data = try? JSONEncoder().encode(cachable) else { return }
        UserDefaults.standard.set(data, forKey: UpdateAvailableManager.cacheKey)
    }
}

// MARK: - Bundle + UpdateAvailableKit

private extension Bundle {
    var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
}

// MARK: - URL + UpdateAvailableKit

private extension URL {
    static func createITunesLookupURL(with bundleID: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/lookup"
        urlComponents.queryItems = [
            .init(name: "bundleId", value: bundleID)
        ]
        return urlComponents.url
    }
}
