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
    
    var movieSummary = [MovieSummaryPresenter]()
    var filter = ListMoviesFilter()
    weak var output: MovieListPresenterOutput?
    
    let wireframe: MovieBrowserWireframe
    
    let interactor: MovieListInteractor
    
    init(wireframe: MovieBrowserWireframe, interactor: MovieListInteractor) {
        self.wireframe = wireframe
        self.interactor = interactor
        interactor.output = self
    }
    
    // MARK: - MovieListPresenter
    
    func loadInitialItems() {
        interactor.fetchFirstPage(filter: filter)
    }

    func loadMoreItems() {
        interactor.fetchNextPage()
    }

    var numberOfItems: Int {
        get {
            movieSummary.count
        }
    }
    
    func configureCell(_ cell: MovieSummaryPresenterOutput, forItemAt index: Int) {
        let presenter = movieSummary[index]
        presenter.output = cell
    }
        
    func showDetailOfItem(at index: Int) {
        guard let ctrl = output else {
            return
        }
        let item = movieSummary[index]
        let subInteractor = interactor.makeDetailInteractor(for: item.movieSummary)
        let subPresenter = MovieDetailPresenterImp(wireframe: wireframe, interactor: subInteractor)
        wireframe.present(movieDetail: subPresenter, from: ctrl)
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
            let summaryPresenters = received.map {
                MovieSummaryPresenterImp(summary: $0)
            }
            self.movieSummary.append(contentsOf: summaryPresenters)
            ctrl.presenter(self, didAddItemsAt: addedItems)
        }
        
    }
    
    func movieList(_ showMovies: MovieListInteractor, didEncounterError error: Error) {
        // TODO: present error
        print("Error: \(error)")
    }

}
