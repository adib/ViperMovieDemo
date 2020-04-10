//
//  MovieOverviewPresenter.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 14/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import DomainEntities
import BusinessLogic

class MovieListPresenterImp: MovieListPresenter, MovieListInteractorOutput {
    
    var movieSummary = [MovieSummary]()
    
    weak var output: MovieListPresenterOutput?
    
    var wireframe: MovieBrowserWireframe
    
    let interactor: MovieListInteractor
    
    init(wireframe: MovieBrowserWireframe, interactor: MovieListInteractor) {
        self.wireframe = wireframe
        self.interactor = interactor
        interactor.output = self
    }
    
    // MARK: - MovieListPresenter
    
    func loadInitialItems() {
        interactor.preferredLocale = Locale.current
        interactor.currentDate = Date()
        interactor.fetchFirstPage()
    }

    func loadMoreItems() {
        interactor.fetchNextPage()
    }

    var numberOfItems: Int {
        get {
            movieSummary.count
        }
    }
    
    var loadBatchSize: Int = 1 {
        didSet {
            if loadBatchSize >= 1 {
                interactor.fetchPageSize = loadBatchSize
            }
        }
    }

    
    func configureCell(_ cell: MovieSummaryCell, forItemAt index: Int) {
        let summary = movieSummary[index]
        cell.movieID = summary.movieID
        cell.setMovieOriginalTitle(summary.originalTitle)
    }
        
    func showDetailOfItem(at index: Int) {
        guard let output = self.output else {
            return
        }
        let item = movieSummary[index]
        let subInteractor = interactor.makeDetailInteractor(for: item)
        let subPresenter = MovieDetailPresenterImp(wireframe: wireframe, interactor: subInteractor)
        wireframe.present(movieDetail: subPresenter, from: output)
    }

    // MARK: MovieListInteractorOutput
    
    func movieList(_ showMovies: MovieListInteractor, didReceiveMovieSummary received: [MovieSummary]) {
        DispatchQueue.main.async {
            guard let ctrl = self.output else {
                return
            }

            let currentCount = self.movieSummary.count
            let newStartIndex = currentCount
            let newLimit = currentCount + received.count
            let addedItems = IndexSet(integersIn: newStartIndex..<newLimit)
            self.movieSummary.append(contentsOf: received)
            ctrl.presenter(self, didAddItemsAt: addedItems)
        }
        
    }
    
    func movieList(_ showMovies: MovieListInteractor, didEncounterError error: Error) {
        guard let viewController = self.output else {
            return
        }
        wireframe.present(error: error, from: viewController) {
            self.loadMoreItems()
        }
    }

}
