//
//  MovieDatabaseClientTestTarget.swift
//  NestedCollectionViewDemoTests
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
@testable import ExternalInterfaces

class MovieDatabaseClientTestTarget: MovieDatabaseClient {
    
    var _baseURL: URL
    var _configuration: URLSessionConfiguration
    
    public init(baseURL: URL, configuration: URLSessionConfiguration) {
        _baseURL = baseURL
        _configuration = configuration
    }
    
    override var baseURL: URL {
        get {
            _baseURL
        }
    }
    
    override var configuration: URLSessionConfiguration {
        get {
            _configuration
        }
    }

}
