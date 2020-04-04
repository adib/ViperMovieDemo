//
//  ShowMoviesUseCase.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 9/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities

class ListMoviesInteractorImp: MovieListInteractor {
    
    
    var currentFilter = ListMoviesFilter()
    
    var currentPage = UInt(1)
    var atLastPage = false
    
    var dataStore: MovieDataStore?
    
    weak var output: MovieListInteractorOutput?

    init() {
        
    }
    
    func fetchCurrentPage() {
        guard let dataProvider = self.dataStore, let delegate = self.output else {
            return
        }
        dataProvider.fetchMovieSummary(filter: currentFilter, page: currentPage) { (returnValue) in
            switch returnValue {
            case .success(let result):
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
        let result = MovieDetailInteractorImp(movieID: movie.movieID)
        result.dataStore = self.dataStore
        return result
    }

    // MARK: - ShowMoviesOverviewInput

    func fetchFirstPage(filter: ListMoviesFilter) {
        currentFilter = filter
        currentPage = 1
        atLastPage = false
        fetchCurrentPage()
    }
    
    func fetchNextPage() {
        guard !atLastPage else {
            return
        }
        currentPage = currentPage + 1
        fetchCurrentPage()
    }
}

