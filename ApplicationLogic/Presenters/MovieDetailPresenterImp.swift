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
        let errorCtrl = UIAlertController(title: NSLocalizedString("Error Encountered", comment: "Generic error title"), message: "\(error)", preferredStyle: .alert)
        errorCtrl.addAction(.init(title: NSLocalizedString("Retry", comment: "Retry Load"), style: .default, handler: { (action) in
            self.refreshDetail()
        }))
        errorCtrl.addAction(.init(title: NSLocalizedString("Ignore", comment: "Ignore error"), style: .cancel, handler:nil))
        viewController.present(errorCtrl, animated: true, completion: nil)
    }

}
