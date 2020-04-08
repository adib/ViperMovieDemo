//
//  MovieDetailPresenterImp.swift
//  InterfaceAdapters
//
//  Created by Sasmito Adibowo on 16/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit
import DomainEntities
import BusinessLogic

class MovieDetailPresenterImp: MovieDetailPresenter {
    
    
    var movieDetail: MovieDetail?
    var wireframe: MovieBrowserWireframe
    var interactor: MovieDetailInteractor
    
    init(wireframe: MovieBrowserWireframe, interactor: MovieDetailInteractor) {
        self.wireframe = wireframe
        self.interactor = interactor
    }
    

    // MARK: -  MovieDetailPresenter
    var output: MovieDetailPresenterOutput?

    var movieTitleText: String?
    
    var movieRuntimeText: String?
    
    var movieTaglineText: String?

    var hasDetail: Bool {
        get {
          movieDetail != nil
        }
    }

    func refreshDetail() {
        
    }

}
