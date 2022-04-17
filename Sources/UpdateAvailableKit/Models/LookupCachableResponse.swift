//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

// MARK: - LookupCachableResponse
struct LookupCachableResponse: Codable {
    let expiryDate: Date
    let response: ITunesLookupResponse
}
