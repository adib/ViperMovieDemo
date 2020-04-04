//
//  MovieDataAdapter.swift
//  InterfaceAdapters
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities
import BusinessLogic


class MovieDataAdapter: MovieDataStore {
    
    
    
    let dataSource: MovieDataProvider
    
    init(dataSource: MovieDataProvider) {
        self.dataSource = dataSource
    }
    
    // MARK: MovieDataStore
    
    func fetchMovieSummary(filter: ListMoviesFilter, page: UInt, resultReceiver: @escaping (Result<[MovieSummary]>) -> Void) {
        switch filter.mode {
        case .discover:
            dataSource.discoverMovies(pageNumber: page) { (response) in
                guard case let .success(result) = response else {
                    resultReceiver(.failure(response.error!))
                    return
                }
                resultReceiver(.success(result.results ?? []))
            }
        }
    }
    
    func fetchMovieImage(identifier: MovieImageIdentifier, resultReceiver: @escaping (Result<MovieImage>) -> Void) {
        // TODO: <#code#>
    }

    func updateFavorite(movie: MovieIdentifier, isFavorite: Bool, resultReceiver: @escaping (Error?) -> Void) {
        // TODO: <#code#>
    }

}
