//
//  Overview.swift
//  InterfaceAdapters
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit
import DomainEntities

// MARK: - User Interface

// MARK: Routers


public protocol MovieBrowserWireframe: class {
    var rootViewController: UIViewController { get }
    func present(movieDetail: MovieDetailPresenter, from: UIViewController)
    func present(error: Error, from sourceVC: UIViewController, retryHandler: (() -> Void)? )
}

public func createMovieBrowserWireframe(dataProvider: MovieDataProvider) -> MovieBrowserWireframe {
    MovieBrowserWireframeImp(dataProvider: dataProvider)
}

// MARK: MovieListPresenter

public protocol MovieListPresenter: class {
    var output: MovieListPresenterOutput? {get set}
    var numberOfItems: Int { get }
    func configureCell(_ cell: MovieSummaryCell, forItemAt: Int)
    func loadInitialItems()
    func loadMoreItems()
    func showDetailOfItem(at indexPath: Int)
    var loadBatchSize: Int { get set }
}


public protocol MovieListPresenterOutput: UIViewController {
    func presenter(_ presenter: MovieListPresenter, didAddItemsAt indexes: IndexSet)
}

// MARK: MovieDetailPresenter

public protocol MovieDetailPresenter: class {
    var output: MovieDetailPresenterOutput? {get set}
    var hasDetail: Bool { get }
    
    var movieTitleText: String? { get }
    var movieRuntimeText: String? { get }
    var movieTaglineText: String? { get }
    var movieReleaseDateText: String? { get }
    
    func refreshDetail()
}


public protocol MovieDetailPresenterOutput: UIViewController {
    func presenterDidUpdateMovieDetail(_ presenter: MovieDetailPresenter)
}



// MARK: Views

public protocol MovieSummaryCell: class {
    var movieID: MovieIdentifier? {get set}
    func setMovieOriginalTitle(_ title: String?)
}


// MARK: View Controllers


protocol DetailViewController: UIViewController {
    var isEmpty: Bool { get }
}


// MARK: - Network


// MARK: Data Provider
public protocol MovieSummaryResult {
    var pageNumber: UInt? { get }
    var totalResults: UInt? { get }
    var totalPages: UInt? { get }
    var results: [MovieSummary]? { get }
}


public protocol MovieDataProvider {
    var defaultPageSize: Int { get }
    func fetchMovieSummaries(
        filter: [(attribute: MovieFilterAttribute, value: Any, isAscending: Bool)],
        sort: (attribute: MovieSortAttribute, isAscending: Bool)?,
        pageNumber: Int?,
        resultReceiver: @escaping ( _ : Result<MovieSummaryResult>) -> Void )
    func fetchMovieDetail(movieID: MovieIdentifier, resultReceiver: @escaping (Result<MovieDetail>) -> Void)
}



