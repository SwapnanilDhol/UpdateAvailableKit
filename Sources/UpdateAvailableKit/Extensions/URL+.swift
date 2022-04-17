/*****************************************************************************
 * URL+.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

extension URL {

    static func createITunesLookupURL(
        with bundleID: String = Bundle.main.bundleIdentifier
    ) -> URL? {
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
