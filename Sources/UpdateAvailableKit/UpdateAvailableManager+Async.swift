//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

// MARK: - Async Alternative
extension UpdateAvailableManager {

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    private func queryITunesForNewResponse(
        with bundleID: String = Bundle.main.bundleIdentifier
    ) async throws -> ITunesLookupResponse {
        guard let url: URL = .createITunesLookupURL(with: bundleID) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: data)
        let cachableReponse: LookupCachableResponse = .init(
            expiryDate: Date().addingTimeInterval(3600),
            response: response
        )
        guard let cachedResponseData = try? JSONEncoder().encode(cachableReponse) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        UserDefaults.standard.set(cachedResponseData, forKey: self.cacheKey)
        return response
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func checkForVersionUpdate(
        with bundleID: String = Bundle.main.bundleIdentifier,
        currentVersion: String = Bundle.main.releaseVersionNumber,
        useCache: Bool = true
    ) async throws -> UpdateAvailableResult {
        if useCache {
            if let cachedData = UserDefaults.standard.data(forKey: cacheKey) {
                let response = try JSONDecoder().decode(LookupCachableResponse.self, from: cachedData)
                if let currentAppStoreVersion = response.response.results?.first?.version,
                   Date() < response.expiryDate {
                    return isAppStoreVersionGreaterThanCurrentVersion(
                        appStoreVersion: currentAppStoreVersion,
                        currentVersion: currentVersion
                    )
                }
            }
        }
        let response = try await queryITunesForNewResponse(with: bundleID)
        if let currentAppStoreVersion = response.results?.first?.version {
            return isAppStoreVersionGreaterThanCurrentVersion(
                appStoreVersion: currentAppStoreVersion,
                currentVersion: currentVersion
            )
        }
        fatalError("Have to Handle this edge case.")
    }
}
