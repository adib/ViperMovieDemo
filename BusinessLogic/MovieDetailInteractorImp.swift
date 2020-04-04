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
    
    var dataStore: MovieDataStore?
    
    weak var output: MovieDetailInteractorOutput?
    
    init(movieID: MovieIdentifier) {
        self.movieID = movieID
    }
 
    func updateFavorite(_ newFavoriteValue: Bool, resultReceiver: @escaping (Error?) -> Void) {
        // TODO
    }

}
