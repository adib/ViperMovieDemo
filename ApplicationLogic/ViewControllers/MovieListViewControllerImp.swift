//
//  DiscoverViewController.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

class MovieListViewControllerImp: UITableViewController, MovieListPresenterOutput {
    
    let movieCellIdentifier = "movieCell"
    
    var isLoaded = false

    var presenter: MovieListPresenter? {
        didSet {
            if let p = presenter {
                p.output = self
            }
        }
    }

    @objc func updateBatchSize() {
        guard let p = presenter else {
            return
        }
        let tableViewSize = self.tableView.bounds.size
        let rowHeight = self.tableView.rowHeight
        let visibleRowCount = Int(ceil( tableViewSize.height / max(rowHeight, 1)))
        p.loadBatchSize = max(visibleRowCount, 1) * 3 / 2
    }
    
    func setNeedsUpdateBatchSize() {
        let sel = #selector(Self.updateBatchSize)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: sel, object: nil)
        self.perform(sel, with: nil, afterDelay: 0)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(MovieOverviewTableViewCellImp.classForCoder(), forCellReuseIdentifier: movieCellIdentifier)
        self.tableView.rowHeight = 44
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNeedsUpdateBatchSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let p = presenter, !isLoaded {
            self.updateBatchSize()
            p.loadInitialItems()
            isLoaded = true
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
        let cell = tableView.dequeueReusableCell(withIdentifier: movieCellIdentifier, for: indexPath) as! MovieOverviewTableViewCellImp
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
