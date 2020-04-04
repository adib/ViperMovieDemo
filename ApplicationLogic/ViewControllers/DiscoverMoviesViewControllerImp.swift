//
//  DiscoverViewController.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

class DiscoverMoviesViewControllerImp: UITableViewController, MovieListPresenterOutput {
    
    let movieCellIdentifier = "movieCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MovieOverviewTableViewCell.classForCoder(), forCellReuseIdentifier: movieCellIdentifier)
        self.tableView.rowHeight = 120
        if let p = presenter {
            p.loadInitialItems()
        }
    }
    
    var presenter: MovieListPresenter? {
        didSet {
            if let p = presenter {
                p.output = self
            }
        }
    }

    // MARK: - Protocol Implementations
    
    // MARK: MovieListPresenterOutput
    
    func presenter(_ presenter: MovieListPresenter, didAddItemsAt indexes: IndexSet) {
        let indexPaths = indexes.map {
            IndexPath(row: $0, section: 0)
        }
        tableView.insertRows(at: indexPaths, with: .automatic)
    }

    // MARK: UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presenter = self.presenter else {
            return 0
        }
        return presenter.numberOfItems
    }
        
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: movieCellIdentifier, for: indexPath) as! MovieOverviewTableViewCell
        if let presenter = self.presenter {
            presenter.configureCell(cell, forItemAt: indexPath.row)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter = self.presenter else {
            return
        }
        presenter.showDetailOfItem(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.superclass?.instancesRespond(to: #selector(scrollViewDidEndDecelerating)) ?? false {
            super.scrollViewDidEndDecelerating(scrollView)
        }
        guard let presenter = self.presenter else {
            return
        }
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
        if bottomEdge >= scrollView.contentSize.height {
            presenter.loadMoreItems()
        }
    }
    
}


