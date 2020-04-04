//
//  MovieDatabaseClientTests.swift
//  NestedCollectionViewDemoTests
//
//  Created by Sasmito Adibowo on 12/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import XCTest
import TestUtilities
import ApplicationLogic
@testable import ExternalInterfaces

class MovieDatabaseClientTests: XCTestCase {

    let baseURL = URL(string: "x-test://moviedb.example.org/3")!
    
    func makeMovieDatabaseClient() -> MovieDatabaseClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [
            LocalResourcesTestProtocolHandler.self
        ]
        return MovieDatabaseClientTestTarget(baseURL: baseURL, configuration: config)
    }
    
    
    func testParseMovieOverview() {
        let discoverComplete = XCTestExpectation(description: "Movie Discovery Completed")
        let targetURL = baseURL.appendingPathComponent("discover/movie")
        LocalResourcesTestProtocolHandler.register(url: targetURL, returning: findTestResource(name: "discover_results", withExtension: "json"), mimeType: "application/json")
        defer {
            LocalResourcesTestProtocolHandler.unregister(url: targetURL)
        }
        let client = makeMovieDatabaseClient()
        client.discoverMovies(pageNumber: 1) { (discoverReturn) in
            defer {
                discoverComplete.fulfill()
            }
            guard case let .success(moviesResult) = discoverReturn else {
                XCTFail("Error returned: \(discoverReturn)")
                return
            }
            XCTAssertEqual(moviesResult.pageNumber, 1, "Wrong page number")
            XCTAssertNotNil(moviesResult.results, "No results array")
            XCTAssertGreaterThan(moviesResult.results?.count ?? 0, 0, "Empty Results")
            if let firstResult = moviesResult.results?.first {
                XCTAssertEqual(firstResult.originalTitle, "A Rainy Day in New York")
            }
        }
        self.wait(for: [discoverComplete], timeout: 60)
    }
}
