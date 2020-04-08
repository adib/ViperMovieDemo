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
    var dataStore: MovieDataStore {get set}
}

// MARK: List Movies


public protocol MovieListInteractor: MovieInteractor {
    
    var output: MovieListInteractorOutput? {get set}
    
    var fetchPageSize: Int {get set }
    
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
    func fetchMovieSummary(filter: ListMoviesFilter, fetchOffset: Int, fetchLimit: Int, resultReceiver: @escaping (Result<[MovieSummary]>) -> Void)
}


public struct ListMoviesFilter {
    public init() {
        
    }
    public enum Mode {
        case discover
    }
    public var mode = Mode.discover
}


public func createMovieListInteractor(dataStore: MovieDataStore) -> MovieListInteractor {
    MovieListInteractorImp(dataStore: dataStore)
}


// Mark: Movie Detail

public protocol MovieDetailInteractor: MovieInteractor {
    var output: MovieDetailInteractorOutput? { get set}
    func fetchDetail()
}

public protocol MovieDetailInteractorOutput: class {
    func movieDetail(_ interactor: MovieDetailInteractor, didReceiveMovieDetail: MovieDetail)
    func movieDetail(_ interactor: MovieDetailInteractor, didEncounterError: Error)
}
