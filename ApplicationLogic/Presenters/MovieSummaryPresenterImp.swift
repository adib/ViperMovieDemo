//
//  MovieSummaryPresenterImp.swift
//  ApplicationLogic
//
//  Created by Sasmito Adibowo on 17/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities

class MovieSummaryPresenterImp: MovieSummaryPresenter {
        
    
    init(summary: MovieSummary) {
        self.movieSummary = summary
    }
    
    func configureOutput() {
        guard let output = self.output else {
            return
        }
        output.movieID = movieSummary.movieID
        output.setMovieOriginalTitle(movieSummary.originalTitle)
    }

    // MARK: MovieSummaryPresenter
    
    var movieSummary: MovieSummary
    
    weak var output: MovieSummaryPresenterOutput? {
        didSet {
            configureOutput()
        }
    }

}
