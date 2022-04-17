//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

final class UpdateAvailableManager {

    static let shared = UpdateAvailableManager()
    private let cacheKey = "UpdateAvailableManager.ITunesCachedData"
    private init() { }

    // MARK: - Version Update

    public func checkForVersionUpdate(
        useCache: Bool = true,
        completion: @escaping((Result<UpdateAvailableResult, Error>) -> Void)
    ) {
        guard let url: URL = .createURLForITunesLookup() else { return }
        if useCache {
            if let cachedData = UserDefaults.standard.data(forKey: cacheKey),
               let response = try? JSONDecoder().decode(LookupCachableResponse.self, from: cachedData),
               let currentAppStoreVersion = response.response.results?.first?.version,
               Date() < response.expiryDate {
                if self.isAppStoreVersionGreaterThanCurrentVersion(appStoreVersion: currentAppStoreVersion) {
                    completion(.success(.updateAvailable(newVersion: currentAppStoreVersion)))
                } else {
                    completion(.success(.noUpdatedAvailable))
                }
                return
            }
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            guard let response = try? JSONDecoder().decode(ITunesLookupResponse.self, from: data) else { return }
            guard let currentAppStoreVersion = response.results?.first?.version else { return }
            if self.isAppStoreVersionGreaterThanCurrentVersion(appStoreVersion: currentAppStoreVersion) {
                completion(.success(.updateAvailable(newVersion: currentAppStoreVersion)))
            } else {
                completion(.success(.noUpdatedAvailable))
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

    private func isAppStoreVersionGreaterThanCurrentVersion(appStoreVersion: String) -> Bool {
        let currentVersion = Bundle.main.releaseVersionNumber
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
