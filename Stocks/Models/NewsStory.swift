//
//  File.swift
//  Stocks
//
//  Created by Nodirbek on 01/06/22.
//

import Foundation

struct NewsStory: Codable {
    let category: String
    let datetime: TimeInterval
    let headline: String
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}
