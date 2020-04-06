//
//  MovieDatabaseClient.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities
import ApplicationLogic


class MovieDatabaseClient: MovieDataProvider {
    
    static let networkSubsystem = NetworkSubsystem.defaultInstance
    
    let jsonQueue: DispatchQueue
    let resultQueue: DispatchQueue
    
    init() {
        let subsystemQueue = type(of: self).networkSubsystem.subsystemQueue
        jsonQueue = DispatchQueue(label:"MovieDatabaseClient-JSON",qos: .default, target:subsystemQueue)
        resultQueue = DispatchQueue(label:"MovieDatabaseClient-Result",qos: .userInitiated, target:subsystemQueue)
    }
        
    var apiKey = "900a1c8214b1686a76c5fd0f50150be0"

    lazy var urlSession = URLSession(configuration: configuration)
    
    var baseURL: URL {
        get {
            URL(string: "https://api.themoviedb.org/3")!
        }
    }

    var configuration: URLSessionConfiguration {
        get {
            URLSessionConfiguration.default
        }
    }

    
    func makeRequest(path: String, queryItems items: [URLQueryItem]) -> URLRequest {
        var queryItems = items
        let url = baseURL.appendingPathComponent(path)
        queryItems.append(URLQueryItem(name:"api_key", value:apiKey))
        var urlComps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComps.queryItems = queryItems
        var request = URLRequest(url: urlComps.url!, cachePolicy: .returnCacheDataElseLoad)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.networkServiceType = .responsiveData
        return request
    }
    
    func getJSONDictionary(request: URLRequest, successHandler: @escaping (Dictionary<String,Any>) -> Void, failureHandler: @escaping(Error?) -> Void) {
        let task = urlSession.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            guard let receivedResponse = response as? HTTPURLResponse else {
                failureHandler(error)
                return
            }
            guard let statusCode = HTTPStatusCode(rawValue: receivedResponse.statusCode) else {
                failureHandler(error)
                return
            }
            guard statusCode.isGood() else {
                failureHandler(NSError(code: statusCode))
                return
            }
            guard let receivedData = data else {
                failureHandler(NSError(code: .noData))
                return
            }
            self.jsonQueue.async {
                guard let jsonDict = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? Dictionary<String,Any> else {
                    failureHandler(NSError(code: .dataParseError))

                    return
                }
                successHandler(jsonDict)
            }
        }
        task.resume()
    }
    
    // MARK: - MovieDataProvider
    
    var defaultPageSize: Int {
        get {
            20
        }
    }
    
    func discoverMovies(pageNumber: Int?, resultReceiver: @escaping (Result<MovieSummaryResult>) -> Void) {
        var queryItems = [
            URLQueryItem(name:"sort_by", value:"popularity.desc")
        ]
        if let page = pageNumber {
            queryItems.append(URLQueryItem(name:"page", value:"\(page)"))
        }
        let request = makeRequest(path:"discover/movie", queryItems: queryItems)
        
        let returnError = {
            (error: Error?) in
            self.resultQueue.async {
                resultReceiver(Result(error: error))
            }
        }
        getJSONDictionary(request: request, successHandler: { (jsonDict) in
            let result = MovieDatabaseDiscoveryResult(json: jsonDict)
            self.resultQueue.async {
                resultReceiver(.success(result))
            }
        }, failureHandler: returnError)
    }
    
    func fetchMovieDetail(movieID: MovieIdentifier, resultReceiver: @escaping (Result<MovieDetail>) -> Void ) {
        
    }
}

struct MovieDatabaseAssumption {
    static let calendar = Calendar(identifier: .iso8601)
    static let timeZone = TimeZone(secondsFromGMT: 0)
    static let locale = Locale(identifier: "en_US_POSIX")
}


struct MovieDatabaseDiscoveryResult : MovieSummaryResult {
    var pageNumber: UInt?
    
    var totalResults: UInt?
    
    var totalPages: UInt?
    
    var results: [MovieSummary]?
    
    init(json: [String:Any]) {
        pageNumber = json["page"] as? UInt
        totalResults = json["total_results"] as? UInt
        totalPages = json["total_pages"] as? UInt
        if let resultsList = json["results"] as? [[String:Any]] {
            results = resultsList.compactMap({MovieDatabaseMovieSummary(json: $0)})
        }
    }
}

struct MovieDatabaseMovieSummary: MovieSummary {
    var movieID: MovieIdentifier
    
    var originalTitle: String?
    
    var originalLanguage: String?
    
    var releaseDate: DateComponents?
    
    init?(json: [String:Any]) {
        guard let id = json["id"] as? UInt64 else {
            return nil
        }
        movieID = MovieDatabaseMovieIdentifier(rawValue: id)
        originalTitle = json["original_title"] as? String
        originalLanguage = json["original_language"] as? String
        if  let releaseDateStr = json["release_date"] as? String,
            let releaseTs = MovieDatabaseMovieSummary.ymdDateFormatter.date(from: releaseDateStr) {
            releaseDate = MovieDatabaseAssumption.calendar.dateComponents([.year, .month, .day], from: releaseTs)
        }
    }
    
    static let ymdDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = MovieDatabaseAssumption.locale
        df.timeZone = MovieDatabaseAssumption.timeZone
        df.calendar = MovieDatabaseAssumption.calendar
        return df
    }()
}


struct MovieDatabaseMovieIdentifier: MovieIdentifier, Equatable {
    
    var rawValue: UInt64

}


