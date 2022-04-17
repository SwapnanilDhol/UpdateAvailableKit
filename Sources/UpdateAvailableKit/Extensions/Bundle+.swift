/*****************************************************************************
 * Bundle+.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public extension Bundle {
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
