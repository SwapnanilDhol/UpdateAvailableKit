import XCTest
@testable import UpdateAvailableKit

final class UpdateAvailableKitTests: XCTestCase {

    private let bundleIdentifier = "com.swapnanildhol.subscriptiontracker"

    func testNoUpdateAvailable() throws {
        let currentVersion = "2.3.4"
        let expectation = expectation(description: "Checking Version")
        UpdateAvailableManager.shared.checkForVersionUpdate(
            with: bundleIdentifier,
            currentVersion: currentVersion,
            useCache: false
        ) { result in
            switch result {
            case .success(let result):
                switch result {
                case .noUpdatesAvailable:
                    expectation.fulfill()
                default:
                    break
                }
            case .failure:
                break
            }
        }
        waitForExpectations(timeout: 10) { error in
            print("Expectation Failed with \(String(describing: error))")
        }
    }

    func testUpdateAvailable() throws {
        let currentVersion = "2.3.3"
        let expectation = expectation(description: "Checking Version")
        UpdateAvailableManager.shared.checkForVersionUpdate(
            with: bundleIdentifier,
            currentVersion: currentVersion,
            useCache: false
        ) { result in
            switch result {
            case .success(let result):
                switch result {
                case .updateAvailable:
                    expectation.fulfill()
                default:
                    break
                }
            case .failure:
                break
            }
        }
        waitForExpectations(timeout: 10) { error in
            print("Expectation Failed with \(String(describing: error))")
        }
    }
}
