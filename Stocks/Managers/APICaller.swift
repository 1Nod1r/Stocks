//
//  APICaller.swift
//  Stocks
//
//  Created by Nodirbek on 23/05/22.
//

import Foundation


final class APICaller {
    
    static let shared = APICaller()
    
    private init(){}
    
    private struct Constants {
        static let ApiKey = "ca6to32ad3i7itb1m4cg"
        static let sandboxApiKey = "sandbox_ca6to32ad3i7itb1m4d0"
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    public func financialMetrics(for symbol: String, completion: @escaping (Result<FinancialMetricsResponse, Error>) -> Void ){
        request(url: url(
            for: .financials,
            queryParams: [
                "symbol": symbol,
                "metric": "all"
            ]),
            expecting: FinancialMetricsResponse.self,
            completion: completion)
    }
    
    
    public func marketData(for symbol: String, numberOfDays: TimeInterval = 7, completion: @escaping (Result<MarketDataResponse, Error>) -> Void ){
        let today = Date().addingTimeInterval(-Constants.day)
        let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
        request(
            url: url(for: .marketData, queryParams: [
                "symbol": symbol,
                "resolution": "1",
                "from": "\(Int(prior.timeIntervalSince1970))",
                "to": "\(Int(today.timeIntervalSince1970))"
            ]),
            expecting: MarketDataResponse.self,
            completion: completion)
        
    }
    
    public func search(query: String, completion: @escaping (Result<SearchResponse, Error>) ->Void){
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(url: url(
            for: .search,
            queryParams: ["q": safeQuery]),
            expecting: SearchResponse.self,
            completion: completion)
    }
    
    public func news(for type: NewsViewController.`Type`, completion: @escaping(Result<[NewsStory], Error>) -> Void){
        switch type {
        case .topStories:
            request(url: url(
                for: .topStories, queryParams: ["category" : "general"]),
                expecting: [NewsStory].self,
                completion: completion)
        case .compan(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(url: url(for: .companyNews, queryParams: [
                "symbol": symbol,
                "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                "to": DateFormatter.newsDateFormatter.string(from: today)
            ]),
                    expecting: [NewsStory].self,
                    completion: completion)
        }
    }
    
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIErrors: Error {
        case invalidUrl
        case noData
        case couldntGetData
    }
    
    private func url(for endpoint: Endpoint,
                     queryParams: [String: String] = [:]
    ) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        var queryItems = [URLQueryItem]()
        
        // Add any parameters
        
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        // Add token
        
        queryItems.append(.init(name: "token", value: Constants.ApiKey))
        urlString += "?" + queryItems.map({"\($0.name)=\($0.value ?? "")"}).joined(separator: "&")
        
        return URL(string: urlString)
    }
    
    private func request<T: Codable>(url: URL?,
                                     expecting: T.Type,
                                     completion: @escaping (Result<T, Error>)->Void) {
        guard let url = url else {
            completion(.failure(APIErrors.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIErrors.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(expecting, from: data)
                completion(.success(result))
            } catch {
                print(error)
                completion(.failure(APIErrors.couldntGetData))
            }
        }
        task.resume()
    }
}
