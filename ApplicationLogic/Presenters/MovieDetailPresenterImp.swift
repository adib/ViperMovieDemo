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

class MovieDetailPresenterImp: MovieDetailPresenter, MovieDetailInteractorOutput {
    
    var movieDetail: MovieDetail?
    
    var wireframe: MovieBrowserWireframe
    
    var interactor: MovieDetailInteractor
    
    lazy var runtimeFormatter: DateComponentsFormatter = {
        var df = DateComponentsFormatter()
        df.allowedUnits = [.minute]
        df.unitsStyle = .full
        df.formattingContext = .standalone
        return df
    }()
    
    lazy var releaseDateFormatter: DateFormatter = {
        var df = DateFormatter()
        df.dateStyle = .full
        df.timeStyle = .none
        df.formattingContext = .standalone
        df.calendar = Calendar.init(identifier: .iso8601)
        return df
    }()
    
    init(wireframe: MovieBrowserWireframe, interactor: MovieDetailInteractor) {
        self.wireframe = wireframe
        self.interactor = interactor
        interactor.output = self
    }
    

    // MARK: -  MovieDetailPresenter
    var output: MovieDetailPresenterOutput?

    var movieTitleText: String? {
        get {
            movieDetail?.originalTitle
        }
    }
    
    var movieRuntimeText: String? {
        get {
            guard   let detail = movieDetail,
                    let movieRuntime = detail.runtime else {
                return nil
            }
            return runtimeFormatter.string(from: movieRuntime)
        }
    }
    
    var movieTaglineText: String? {
        get {
            movieDetail?.tagline
        }
    }
    
    var movieReleaseDateText: String? {
        get {
            guard   let detail = movieDetail,
                    var movieReleaseDate = detail.releaseDate else {
                return nil
            }
            movieReleaseDate.calendar = releaseDateFormatter.calendar
            guard let date = movieReleaseDate.date else {
                return nil
            }
            return releaseDateFormatter.string(for: date)
        }
    }


    var hasDetail: Bool {
        get {
          movieDetail != nil
        }
    }
    

    func refreshDetail() {
        interactor.fetchDetail()
    }
    
    // MARK: - MovieDetailInteractorOutput
    
    func movieDetail(_ interactor: MovieDetailInteractor, didReceiveMovieDetail detail: MovieDetail) {
        movieDetail = detail
        guard let viewController = self.output else {
            return
        }
        viewController.presenterDidUpdateMovieDetail(self)
    }
    
    func movieDetail(_ interactor: MovieDetailInteractor, didEncounterError error: Error) {
        guard let viewController = self.output else {
            return
        }
        wireframe.present(error: error, from: viewController) {
            self.refreshDetail()
        }
    }

}
