/*****************************************************************************
 * LookupCachableResponse.swift
 * UpdateAvailableKit
 *****************************************************************************
 * Copyright (c) 2022 Swapnanil Dhol. All rights reserved.
 *
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the LICENSE.md file of the official project for license.
 *****************************************************************************/
import Foundation

struct LookupCachableResponse: Codable {
    let expiryDate: Date
    let response: ITunesLookupResponse
}
