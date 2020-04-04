//
//  InteractorInterfaces.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 9/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities


public protocol MovieInteractor: class {
    var dataStore: MovieDataStore? {get set}
}

// MARK: List Movies


public protocol MovieListInteractor: MovieInteractor {
    
    var output: MovieListInteractorOutput? {get set}
    
    var currentFilter: ListMoviesFilter {get}
    
    func fetchFirstPage(filter: ListMoviesFilter)
    
    func fetchNextPage()
        
    func makeDetailInteractor(for: MovieSummary) -> MovieDetailInteractor
    
}

public protocol MovieListInteractorOutput: class {
    func movieList(_ showMovies: MovieListInteractor, didReceiveMovieSummary: [MovieSummary])
    func movieList(_ showMovies: MovieListInteractor, didEncounterError: Error)
}


public protocol MovieDataStore: class {
    func fetchMovieSummary(filter: ListMoviesFilter, page: UInt, resultReceiver: @escaping (Result<[MovieSummary]>) -> Void)
    func fetchMovieImage(identifier: MovieImageIdentifier, resultReceiver: @escaping (Result<MovieImage>) -> Void)
    
    func updateFavorite(movie: MovieIdentifier, isFavorite: Bool, resultReceiver: @escaping (Error?) -> Void)
}


public struct ListMoviesFilter {
    public init() {
        
    }
    public enum Mode {
        case discover
    }
    public var mode = Mode.discover
}


public func makeListMoviesInteractor() -> MovieListInteractor {
    ListMoviesInteractorImp()
}


// Mark: Movie Detail

public protocol MovieDetailInteractor: MovieInteractor {
    var output: MovieDetailInteractorOutput? { get set}
    
    func updateFavorite(_ newFavoriteValue: Bool, resultReceiver: @escaping (Error?) -> Void)
}

public protocol MovieDetailInteractorOutput: class {
    
}
