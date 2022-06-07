//
//  SearchResponse.swift
//  Stocks
//
//  Created by Nodirbek on 25/05/22.
//

import Foundation

struct SearchResponse: Codable {
    let count: Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}

