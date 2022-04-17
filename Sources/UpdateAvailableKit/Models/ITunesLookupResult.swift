/*****************************************************************************
 * ITunesLookupResult.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

struct ITunesLookupResult: Codable {
    let minimumOSVersion: String?
    let sellerName, version, wrapperType: String?

    enum CodingKeys: String, CodingKey {
        case minimumOSVersion = "minimumOsVersion"
        case sellerName, version, wrapperType
    }
}
