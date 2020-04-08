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
    
    func getJSONObject<ObjectImplementation, ObjectInterface>(request: URLRequest, concreteObject: ObjectImplementation.Type, resultReceiver: @escaping (Result<ObjectInterface>) -> Void) where ObjectImplementation: JSONDictionaryInitializable  {
        let returnError = {
            (error: Error?) in
            self.resultQueue.async {
                resultReceiver(Result(error: error))
            }
        }
        getJSONDictionary(request: request, successHandler: { (jsonDict) in
            guard let result = ObjectImplementation.init(json: jsonDict) else {
                returnError(NSError(code: .dataParseError))
                return
            }
            guard let resultInterface = result as? ObjectInterface else {
                returnError(NSError(code: .internalError))
                return
            }
            self.resultQueue.async {
                resultReceiver(.success(resultInterface))
            }
        }, failureHandler: returnError)

    }
    
    // MARK: - MovieDataProvider
    
    var defaultPageSize: Int {
        get {
            20
        }
    }
    
    func fetchMovieSummaries(filter: [(attribute: MovieFilterAttribute, value: Any, isAscending: Bool)], sort: (attribute: MovieSortAttribute, isAscending: Bool)?, pageNumber: Int?, resultReceiver: @escaping (Result<MovieSummaryResult>) -> Void) {
        var queryItems = [URLQueryItem]()
        queryItems.reserveCapacity(filter.count + 2)
        for filterEntry in filter {
            switch filterEntry.attribute {
            case .isAdult:
                queryItems.append(.init(name: "include_adult", value: (filterEntry.value as? Bool ?? false) ? "true" : "false"))
            case .language:
                if let language = filterEntry.value as? String {
                    queryItems.append(.init(name: "language", value: language))
                }
            case .releaseDate:
                if let dateStr = formatYMD(dateValue: filterEntry.value) {
                    let filterName = filterEntry.isAscending ? "release_date.lte" : "release_date.gte"
                    queryItems.append(.init(name: filterName, value: dateStr))
                }
            }
        }
        if let page = pageNumber {
            queryItems.append(URLQueryItem(name:"page", value:"\(page)"))
        }
        let request = makeRequest(path:"discover/movie", queryItems: queryItems)
        getJSONObject(request: request, concreteObject: MovieDatabaseDiscoveryResult.self, resultReceiver: resultReceiver)
    }
    
    func fetchMovieDetail(movieID: MovieIdentifier, resultReceiver: @escaping (Result<MovieDetail>) -> Void) {
        let idValue = movieID as! MovieDatabaseMovieIdentifier
        let request = makeRequest(path:"movie/\(idValue.rawValue)", queryItems: [])
        getJSONObject(request: request, concreteObject: MovieDatabaseMovieDetail.self, resultReceiver: resultReceiver)
    }
}

protocol JSONDictionaryInitializable {
    init?(json: [String:Any])
}

struct MovieDatabaseAssumption {
    static let calendar = Calendar(identifier: .iso8601)
    static let timeZone = TimeZone(secondsFromGMT: 0)
    static let locale = Locale(identifier: "en_US_POSIX")
    
    static let ymdDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Self.locale
        df.timeZone = Self.timeZone
        df.calendar = Self.calendar
        return df
    }()
}


func parseYMD(dateString: Any?) -> DateComponents? {
    guard let str = dateString as? String else {
        return nil
    }
    guard let dateTS = MovieDatabaseAssumption.ymdDateFormatter.date(from: str) else {
        return nil
    }
    let dateComps = MovieDatabaseAssumption.calendar.dateComponents([.year, .month, .day], from: dateTS)
    return dateComps
}

func formatYMD(dateValue: Any?) -> String? {
    guard let date = dateValue as? Date else {
        return nil
    }
    let dateStr = MovieDatabaseAssumption.ymdDateFormatter.string(from: date)
    return dateStr
}

struct MovieDatabaseDiscoveryResult : MovieSummaryResult, JSONDictionaryInitializable {
    var pageNumber: UInt?
    
    var totalResults: UInt?
    
    var totalPages: UInt?
    
    var results: [MovieSummary]?
    
    init?(json: [String:Any]) {
        pageNumber = json["page"] as? UInt
        totalResults = json["total_results"] as? UInt
        totalPages = json["total_pages"] as? UInt
        if let resultsList = json["results"] as? [[String:Any]] {
            results = resultsList.compactMap({MovieDatabaseMovieSummary(json: $0)})
        }
    }
}


struct MovieDatabaseMovieSummary: MovieSummary, JSONDictionaryInitializable {
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
        releaseDate = parseYMD(dateString: json["release_date"])
    }
    
}


struct MovieDatabaseMovieIdentifier: MovieIdentifier, Equatable {
    
    var rawValue: UInt64

}


struct MovieDatabaseMovieDetail: MovieDetail, JSONDictionaryInitializable {
    var tagline: String?
    
    var runtime: TimeInterval?
        
    var originalTitle: String?
    
    var originalLanguage: String?
    
    var releaseDate: DateComponents?
    
    var movieID: MovieIdentifier
    
    init?(json: [String : Any]) {
        guard let id = json["id"] as? UInt64 else {
            return nil
        }
        movieID = MovieDatabaseMovieIdentifier(rawValue: id)
        originalTitle = json["original_title"] as? String
        originalLanguage = json["original_language"] as? String
        releaseDate = parseYMD(dateString: json["release_date"])
        
        tagline = json["tagline"] as? String
        if let runtimeValue = json["runtime"] as? Float {
            runtime = TimeInterval(runtimeValue * 60)
        }
    }
}

