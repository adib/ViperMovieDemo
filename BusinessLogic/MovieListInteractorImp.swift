//
//  ShowMoviesUseCase.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 9/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities

class MovieListInteractorImp: MovieListInteractor {
    
    var currentFetch = MovieFetchRequest()
    
    var lastFetchCount: Int?
    
    var atLastPage = false
    
    var dataStore: MovieDataStore
    
    weak var output: MovieListInteractorOutput?

    init(dataStore: MovieDataStore) {
        self.dataStore = dataStore
    }
    
    func fetchCurrentPage() {
        guard let delegate = self.output else {
            return
        }
        dataStore.fetchMovieSummary(request: self.currentFetch) {
            (returnValue) in
            switch returnValue {
            case .success(let result):
                self.lastFetchCount = result.count
                if result.count == 0 {
                    self.atLastPage = true
                }
                delegate.movieList(self, didReceiveMovieSummary: result)
            case .failure(let error):
                delegate.movieList(self, didEncounterError: error)
            }
        }
    }
        
    func makeDetailInteractor(for movie: MovieSummary) -> MovieDetailInteractor {
        let result = MovieDetailInteractorImp(movieID: movie.movieID, dataStore: dataStore)
        return result
    }

    // MARK: - MovieListInteractor

    var preferredLocale: Locale?

    var fetchPageSize = 53

    func fetchFirstPage() {
        var fetch = MovieFetchRequest()
        fetch.fetchLimit = fetchPageSize
        fetch.filters = [
            (.isAdult, false, false)
        ]
        fetch.sort = (.popularity, false)
        fetch.fetchOffset = 0
        currentFetch = fetch
        
        lastFetchCount = nil
        atLastPage = false
        fetchCurrentPage()
    }
    
    func fetchNextPage() {
        guard !atLastPage else {
            return
        }
        currentFetch.fetchOffset += lastFetchCount ?? 0
        fetchCurrentPage()
    }
}

