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
    
    var currentFilter = ListMoviesFilter()

    var currentFetchOffset = 0
    
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
        dataStore.fetchMovieSummary(filter: currentFilter, fetchOffset: currentFetchOffset, fetchLimit: fetchPageSize) {
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

    var fetchPageSize = 53

    func fetchFirstPage(filter: ListMoviesFilter) {
        currentFilter = filter
        currentFetchOffset = 0
        lastFetchCount = nil
        atLastPage = false
        fetchCurrentPage()
    }
    
    func fetchNextPage() {
        guard !atLastPage else {
            return
        }
        currentFetchOffset += lastFetchCount ?? 0
        fetchCurrentPage()
    }
}

