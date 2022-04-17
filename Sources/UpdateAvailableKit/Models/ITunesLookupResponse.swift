//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

struct ITunesLookupResponse: Codable {
    let resultCount: Int?
    let results: [ITunesLookupResult]?
}
