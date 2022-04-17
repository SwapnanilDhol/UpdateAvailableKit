//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

struct ITunesLookupResult: Codable {
    let minimumOSVersion: String?
    let sellerName, version, wrapperType: String?

    enum CodingKeys: String, CodingKey {
        case minimumOSVersion = "minimumOsVersion"
        case sellerName, version, wrapperType
    }
}
