//
//  File.swift
//  
//
//  Created by Swapnanil Dhol on 17/04/22.
//

import Foundation

extension URL {

    static func createURLForITunesLookup() -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/lookup"
        urlComponents.queryItems = [
            .init(name: "bundleId", value: Bundle.main.bundleIdentifier)
        ]
        return urlComponents.url
    }
}
