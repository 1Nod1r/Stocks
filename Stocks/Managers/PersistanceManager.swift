//
//  PersistanceManager.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import Foundation

class PersistanceManager {
    static let shared = PersistanceManager()
    
    private let userDefaults = UserDefaults.standard
    
    struct Constants {
        static let onBoardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }
    
    private init(){}
    
    public func watchlistContains(symbol: String) -> Bool {
        return watchList.contains(symbol)
    }
    
    public var watchList: [String] {
        if !hasOnBoarded {
            userDefaults.set(true, forKey: Constants.onBoardedKey)
            setupDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    public func addToWatchList(symbol: String, companyName: String){
        var current = watchList
        current.append(symbol)
        userDefaults.set(current, forKey: Constants.watchlistKey)
        userDefaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddWatchlist, object: nil)
    }
    
    public func removeToWatchList(symbol: String){
        var newList = [String]()
        print("Deleted: \(symbol)")
        userDefaults.set(nil, forKey: symbol)
        for item in watchList where item != symbol {
            print(item)
            newList.append(item)
        }
        userDefaults.set(newList, forKey: Constants.watchlistKey)
    }
    
    private var hasOnBoarded: Bool {
        return userDefaults.bool(forKey: Constants.onBoardedKey)
    }
    
    private func setupDefaults(){
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc",
            "GOOG": "Alphabet",
            "AMZN": "Amazon.com, Inc",
            "WORK": "Slack Technologies",
            "FB": "Facebook Inc",
            "NVDA": "Nvidia Inc",
            "NKE": "Nike",
            "PINS": "Pinterest Inc"
        ]
        
        let symbols = map.keys.map{ $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
