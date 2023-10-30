/*****************************************************************************
 * UpdateAvailableManager.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 * Rudrank Riyam <rudrankriyam # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public final class UpdateAvailableManager {

    public static let shared = UpdateAvailableManager()
    let cacheKey = "UpdateAvailableManager.ITunesCachedData"
    private init() { }

    // MARK: - Completion Handler Based Methods

    private func queryITunesForNewResponse(
        with bundleID: String = Bundle.main.bundleIdentifier,
        completion: @escaping((Result<ITunesLookupResponse, Error>) -> Void)
    ) {
        guard let url: URL = .createITunesLookupURL(with: bundleID) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            guard let response = try? JSONDecoder().decode(ITunesLookupResponse.self, from: data) else { return }
            let cachableReponse: LookupCachableResponse = .init(
                expiryDate: Date().addingTimeInterval(3600),
                response: response
            )
            guard let cachedResponseData = try? JSONEncoder().encode(cachableReponse) else { return }
            UserDefaults.standard.set(cachedResponseData, forKey: self.cacheKey)
            completion(.success(response))
        }
        .resume()
    }

    public func checkForVersionUpdate(
        with bundleID: String = Bundle.main.bundleIdentifier,
        currentVersion: String = Bundle.main.releaseVersionNumber,
        useCache: Bool = true,
        completion: @escaping((Result<UpdateAvailableResult, Error>) -> Void)
    ) {
        if useCache {
            if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
               let response = try? JSONDecoder().decode(LookupCachableResponse.self, from: cachedData),
               let currentAppStoreVersion = response.response.results?.first?.version,
               Date() < response.expiryDate {
                let successResult = self.isAppStoreVersionGreaterThanCurrentVersion(
                    appStoreVersion: currentAppStoreVersion,
                    currentVersion: currentVersion
                )
                completion(.success(successResult))
                return
            }
        }
        queryITunesForNewResponse(with: bundleID) { result in
            switch result {
            case .success(let response):
                if let currentAppStoreVersion = response.results?.first?.version {
                    let successResult = self.isAppStoreVersionGreaterThanCurrentVersion(
                        appStoreVersion: currentAppStoreVersion,
                        currentVersion: currentVersion
                    )
                    completion(.success(successResult))
                }
            case .failure:
                break
            }
        }
    }

    // MARK: - Utility Methods

    public func isAppStoreVersionGreaterThanCurrentVersion(
        appStoreVersion: String,
        currentVersion: String
    ) -> UpdateAvailableResult {
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
}
