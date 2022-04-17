/*****************************************************************************
 * UpdateAvailableManager.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

enum UpdateAvailableKitError: Error {
    case appStoreVersionMissing(for: ITunesLookupResult?)
}

extension UpdateAvailableKitError: CustomStringConvertible {
    var description: String {
        switch self {
#warning("Add relevant error description")
            case .appStoreVersionMissing(let result):
                return "App Store version missing for \(String(describing: result))"
        }
    }
}

public final class UpdateAvailableManager {

    public static let shared = UpdateAvailableManager()
    private let cacheKey = "UpdateAvailableManager.ITunesCachedData"
    private init() { }

    // MARK: - Version Update
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func checkForVersionUpdate(
        with bundleID: String = Bundle.main.bundleIdentifier,
        currentVersion: String = Bundle.main.releaseVersionNumber,
        useCache: Bool = true) async throws -> UpdateAvailableResult {
            guard let url: URL = .createITunesLookupURL(with: bundleID) else {
                throw URLError(.badURL)
            }

            if useCache {
                if let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
                    let response = try JSONDecoder().decode(LookupCachableResponse.self, from: cachedData)

                    if let currentAppStoreVersion = response.response.results?.first?.version,
                       Date() < response.expiryDate {
                        if self.isAppStoreVersionGreaterThanCurrentVersion(
                            appStoreVersion: currentAppStoreVersion,
                            currentVersion: currentVersion
                        ) {
                            return .updateAvailable(newVersion: currentAppStoreVersion)
                        } else {
                            return .noUpdatesAvailable
                        }
                    } else {
                        return .noUpdatesAvailable
                    }
                } else {
                    return .noUpdatesAvailable
                }
            } else {
                let (data, _) = try await URLSession.shared.data(from: url)
                let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)

                guard let currentAppStoreVersion = response.results?.first?.version else {
                    throw UpdateAvailableKitError.appStoreVersionMissing(for: response.results?.first)
                }

                let cachableReponse: LookupCachableResponse = .init(
                    expiryDate: Date().addingTimeInterval(3600),
                    response: response
                )

                let cachedResponseData = try JSONEncoder().encode(cachableReponse)
                UserDefaults.standard.set(cachedResponseData, forKey: self.cacheKey)

                if isAppStoreVersionGreaterThanCurrentVersion(
                    appStoreVersion: currentAppStoreVersion,
                    currentVersion: currentVersion
                ) {
                    return .updateAvailable(newVersion: currentAppStoreVersion)
                } else {
                    return .noUpdatesAvailable
                }
            }
        }

    public func checkForVersionUpdate(
        with bundleID: String = Bundle.main.bundleIdentifier,
        currentVersion: String = Bundle.main.releaseVersionNumber,
        useCache: Bool = true,
        completion: @escaping((Result<UpdateAvailableResult, Error>) -> Void)
    ) {
        guard let url: URL = .createITunesLookupURL(with: bundleID) else { return }
        if useCache {
            if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
               let response = try? JSONDecoder().decode(LookupCachableResponse.self, from: cachedData),
               let currentAppStoreVersion = response.response.results?.first?.version,
               Date() < response.expiryDate {
                if self.isAppStoreVersionGreaterThanCurrentVersion(
                    appStoreVersion: currentAppStoreVersion,
                    currentVersion: currentVersion
                ) {
                    completion(.success(.updateAvailable(newVersion: currentAppStoreVersion)))
                } else {
                    completion(.success(.noUpdatesAvailable))
                }
                return
            }
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            guard let response = try? JSONDecoder().decode(ITunesLookupResponse.self, from: data) else { return }
            guard let currentAppStoreVersion = response.results?.first?.version else { return }
            if self.isAppStoreVersionGreaterThanCurrentVersion(
                appStoreVersion: currentAppStoreVersion,
                currentVersion: currentVersion
            ) {
                completion(.success(.updateAvailable(newVersion: currentAppStoreVersion)))
            } else {
                completion(.success(.noUpdatesAvailable))
            }
            let cachableReponse: LookupCachableResponse = .init(
                expiryDate: Date().addingTimeInterval(3600),
                response: response
            )
            guard let cachedResponseData = try? JSONEncoder().encode(cachableReponse) else { return }
            UserDefaults.standard.set(cachedResponseData, forKey: self.cacheKey)
        }
        .resume()
    }

    // MARK: - Utility Methods

    private func isAppStoreVersionGreaterThanCurrentVersion(
        appStoreVersion: String,
        currentVersion: String
    ) -> Bool {
        let currentVersionComponents = currentVersion.components(separatedBy: ".")
        let appStoreVersionComponents = appStoreVersion.components(separatedBy: ".")
        var index = 0
        while index < appStoreVersionComponents.count {
            let appStoreComponent = Int(appStoreVersionComponents[index]) ?? 0
            let currentVersionComponent = Int(currentVersionComponents[index]) ?? 0
            if appStoreComponent > currentVersionComponent {
                return true
            } else if appStoreComponent < currentVersionComponent {
                return false
            }
            index += 1
        }
        return false
    }
}
