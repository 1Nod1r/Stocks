//
//  MarketDataResponse.swift
//  Stocks
//
//  Created by Nodirbek on 03/06/22.
//

import Foundation

struct MarketDataResponse: Codable {
    let open: [Double]
    let close: [Double]
    let high: [Double]
    let status: String
    let low: [Double]
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case high = "h"
        case status = "s"
        case low = "l"
        case timestamps = "t"
    }
    
    var candleStick: [CandleStick] {
        var result = [CandleStick]()
        for index in 0..<open.count {
            result.append(CandleStick(
                high: high[index],
                low: low[index],
                open: open[index],
                close: close[index],
                date: Date(timeIntervalSince1970: timestamps[index])))
        }
        let sortedData = result.sorted { $0.date > $1.date }
        return sortedData
    }
}

struct CandleStick {
    let high: Double
    let low: Double
    let open: Double
    let close: Double
    let date: Date
}
