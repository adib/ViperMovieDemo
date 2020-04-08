//
//  MovieDetailInteractorOutput.swift
//  UseCases
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities

class MovieDetailInteractorImp: MovieDetailInteractor {
    
    
    let movieID: MovieIdentifier
    
    var dataStore: MovieDataStore
    
    
    init(movieID: MovieIdentifier, dataStore: MovieDataStore) {
        self.movieID = movieID
        self.dataStore = dataStore
    }
 
    // MARK: MovieDetailInteractor
    
    weak var output: MovieDetailInteractorOutput?


    func fetchDetail() {
        guard let output = self.output else {
            return
        }
    }

}
