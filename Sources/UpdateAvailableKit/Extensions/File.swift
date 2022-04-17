//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String {
        guard let shortVersionString = infoDictionary?["CFBundleShortVersionString"] as? String else { return " " }
        return shortVersionString
    }
    var buildVersionNumber: String {
        guard let buildVersionNumber = infoDictionary?["CFBundleVersion"] as? String else { return " " }
        return buildVersionNumber
    }

    var bundleIdentifier: String {
        guard let bundleIdentifier = infoDictionary?["CFBundleIdentifier"] as? String else { return " " }
        return bundleIdentifier
    }
}
