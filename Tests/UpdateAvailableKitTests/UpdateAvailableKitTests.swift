/*****************************************************************************
 * UpdateAvailableKitTests.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation
import Testing
@testable import UpdateAvailableKit

struct UpdateAvailableKitTests {
    
    // MARK: - UpdateAvailableResult Tests
    
    @Test func testUpdateAvailableResultEquatableUpdateAvailable() {
        let result1 = UpdateAvailableResult.updateAvailable(newVersion: "2.0.0")
        let result2 = UpdateAvailableResult.updateAvailable(newVersion: "2.0.0")
        #expect(result1 == result2)
    }
    
    @Test func testUpdateAvailableResultEquatableNoUpdatesAvailable() {
        let result1 = UpdateAvailableResult.noUpdatesAvailable
        let result2 = UpdateAvailableResult.noUpdatesAvailable
        #expect(result1 == result2)
    }
    
    @Test func testUpdateAvailableResultNotEqual() {
        let result1 = UpdateAvailableResult.updateAvailable(newVersion: "2.0.0")
        let result2 = UpdateAvailableResult.noUpdatesAvailable
        #expect(result1 != result2)
    }
    
    @Test func testUpdateAvailableResultDifferentVersionsNotEqual() {
        let result1 = UpdateAvailableResult.updateAvailable(newVersion: "2.0.0")
        let result2 = UpdateAvailableResult.updateAvailable(newVersion: "3.0.0")
        #expect(result1 != result2)
    }
    
    @Test func testUpdateAvailableResultAssociatedValue() {
        let result = UpdateAvailableResult.updateAvailable(newVersion: "2.3.4")
        if case .updateAvailable(let version) = result {
            #expect(version == "2.3.4")
        } else {
            Issue.record("Expected updateAvailable case")
        }
    }
    
    // MARK: - Version Comparison Tests
    
    @Test func testMajorVersionGreater() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "2.0.0", currentVersion: "1.0.0")
        #expect(result == .updateAvailable(newVersion: "2.0.0"))
    }
    
    @Test func testMinorVersionGreater() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.3.0", currentVersion: "1.2.0")
        #expect(result == .updateAvailable(newVersion: "1.3.0"))
    }
    
    @Test func testPatchVersionGreater() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.2", currentVersion: "1.0.1")
        #expect(result == .updateAvailable(newVersion: "1.0.2"))
    }
    
    @Test func testSameVersionNoUpdate() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.0", currentVersion: "1.0.0")
        #expect(result == .noUpdatesAvailable)
    }
    
    @Test func testCurrentVersionGreaterNoUpdate() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.0", currentVersion: "2.0.0")
        #expect(result == .noUpdatesAvailable)
    }
    
    @Test func testMinorVersionLowerNoUpdate() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.5.0", currentVersion: "1.8.0")
        #expect(result == .noUpdatesAvailable)
    }
    
    @Test func testPatchVersionLowerNoUpdate() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.5", currentVersion: "1.0.9")
        #expect(result == .noUpdatesAvailable)
    }
    
    @Test func testDifferentLengthVersionsAppStoreLonger() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.1", currentVersion: "1.0")
        #expect(result == .updateAvailable(newVersion: "1.0.1"))
    }
    
    @Test func testDifferentLengthVersionsCurrentLonger() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0", currentVersion: "1.0.1")
        #expect(result == .noUpdatesAvailable)
    }
    
    @Test func testThreeComponentVsTwoComponentAppStoreGreater() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.2.3", currentVersion: "1.2")
        #expect(result == .updateAvailable(newVersion: "1.2.3"))
    }
    
    @Test func testMajorVersionOnlyAppStoreGreater() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "3.0.0", currentVersion: "2.9.9")
        #expect(result == .updateAvailable(newVersion: "3.0.0"))
    }
    
    @Test func testFourComponentVersions() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0.0.1", currentVersion: "1.0.0.0")
        #expect(result == .updateAvailable(newVersion: "1.0.0.1"))
    }
    
    @Test func testVersionComparisonEdgeCaseEqualWithDifferentLengths() {
        let result = UpdateAvailableManager.compare(appStoreVersion: "1.0", currentVersion: "1.0.0.0")
        #expect(result == .noUpdatesAvailable)
    }
    
    // MARK: - ITunesLookupResponse Codable Tests
    
    @Test func testITunesLookupResponseCodable() throws {
        let json = """
        {
            "resultCount": 1,
            "results": [
                {
                    "version": "2.3.4",
                    "minimumOsVersion": "15.0",
                    "sellerName": "Test",
                    "wrapperType": "software"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: json)
        #expect(response.resultCount == 1)
        #expect(response.results?.count == 1)
        #expect(response.results?.first?.version == "2.3.4")
    }
    
    @Test func testITunesLookupResponseCodableEmptyResults() throws {
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: json)
        #expect(response.resultCount == 0)
        #expect(response.results?.isEmpty == true)
    }
    
    @Test func testITunesLookupResponseCodableNilResults() throws {
        let json = """
        {
            "resultCount": 0
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ITunesLookupResponse.self, from: json)
        #expect(response.resultCount == 0)
        #expect(response.results == nil)
    }
    
    @Test func testITunesLookupResultCodable() throws {
        let json = """
        {
            "version": "2.3.4",
            "minimumOsVersion": "15.0",
            "sellerName": "Test Seller",
            "wrapperType": "software"
        }
        """.data(using: .utf8)!
        
        let result = try JSONDecoder().decode(ITunesLookupResult.self, from: json)
        #expect(result.version == "2.3.4")
        #expect(result.minimumOSVersion == "15.0")
        #expect(result.sellerName == "Test Seller")
        #expect(result.wrapperType == "software")
    }
    
    @Test func testITunesLookupResultCodableMinimumOsVersionKeyMapping() throws {
        let json = """
        {
            "minimumOsVersion": "15.0"
        }
        """.data(using: .utf8)!
        
        let result = try JSONDecoder().decode(ITunesLookupResult.self, from: json)
        #expect(result.minimumOSVersion == "15.0")
    }
    
    // MARK: - UpdateAvailableConfiguration Tests
    
    @Test func testConfigurationDefaultValues() {
        let config = UpdateAvailableConfiguration()
        #expect(config.bundleID == nil)
        #expect(config.cacheDuration == 3600)
    }
    
    @Test func testConfigurationCustomValues() {
        let config = UpdateAvailableConfiguration(bundleID: "com.test.app", cacheDuration: 7200)
        #expect(config.bundleID == "com.test.app")
        #expect(config.cacheDuration == 7200)
    }
    
    // MARK: - Integration Tests
    
    @Test func testUpdateAvailableWithVersionLowerThanAppStore() async {
        let bundleID = "com.swapnanildhol.SubscriptionTracker"
        let result = await UpdateAvailableManager.shared.checkForVersionUpdate(
            with: bundleID,
            currentVersion: "1.0.0"
        )
        if case .updateAvailable = result {
            #expect(true)
        } else {
            Issue.record("Expected updateAvailable case")
        }
    }
    
    @Test func testNoUpdateWhenCurrentVersionHigherThanAppStore() async {
        let bundleID = "com.swapnanildhol.SubscriptionTracker"
        let result = await UpdateAvailableManager.shared.checkForVersionUpdate(
            with: bundleID,
            currentVersion: "99.0.0"
        )
        #expect(result == .noUpdatesAvailable)
    }
    
    // MARK: - LookupCachableResponse Tests
    
    @Test func testLookupCachableResponseCodable() throws {
        let innerResponse = ITunesLookupResponse(resultCount: 1, results: nil)
        let expiry = Date().addingTimeInterval(3600)
        let cachable = LookupCachableResponse(expiryDate: expiry, response: innerResponse)
        
        let encoded = try JSONEncoder().encode(cachable)
        let decoded = try JSONDecoder().decode(LookupCachableResponse.self, from: encoded)
        
        #expect(decoded.expiryDate == expiry)
        #expect(decoded.response.resultCount == 1)
    }
    
    @Test func testLookupCachableResponseExpiryDateInFuture() throws {
        let innerResponse = ITunesLookupResponse(resultCount: 1, results: nil)
        let futureDate = Date().addingTimeInterval(3600)
        let cachable = LookupCachableResponse(expiryDate: futureDate, response: innerResponse)
        
        #expect(Date() < cachable.expiryDate)
    }
    
    @Test func testLookupCachableResponseExpiryDateInPast() throws {
        let innerResponse = ITunesLookupResponse(resultCount: 1, results: nil)
        let pastDate = Date().addingTimeInterval(-3600)
        let cachable = LookupCachableResponse(expiryDate: pastDate, response: innerResponse)
        
        #expect(Date() > cachable.expiryDate)
    }
    
}
