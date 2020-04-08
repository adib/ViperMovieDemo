//
//  MovieDetailViewControllerImp.swift
//  ApplicationLogic
//
//  Created by Sasmito Adibowo on 5/4/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit



class MovieDetailViewControllerImp: UITableViewController, DetailViewController, MovieDetailPresenterOutput {
    
    
        
    let placeholderCellIdentifier = "placeholderCell"
    
    let textCellIdentifier = "textCell"
    
    enum DetailRow: Int {
        case title
        case tagline
        case releaseDate
        case runtime
        case end
    }
    
    var presenter: MovieDetailPresenter? {
        didSet {
            guard let p = presenter else {
                return
            }
            p.output = self
        }
    }
        
    
    
    // MARK: - DetailViewController
    var isEmpty: Bool {
        get { presenter == nil }
    }
    
    // MARK: - MovieDetailPresenterOutput
    
    func presenterDidUpdateMovieDetail(_ presenter: MovieDetailPresenter) {
        if isViewLoaded {
            self.tableView.reloadData()
        }
    }

    // MARK: - UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let presenter = self.presenter else {
            return
        }
        presenter.refreshDetail()
    }
    
    // MARK: - UITableViewController
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard presenter?.hasDetail ?? false else {
            return 1
        }
        return DetailRow.end.rawValue
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let presenter = self.presenter, presenter.hasDetail else {
            var detailCell = tableView.dequeueReusableCell(withIdentifier: placeholderCellIdentifier)
            if detailCell == nil {
                detailCell = UITableViewCell(style: .default, reuseIdentifier: placeholderCellIdentifier)
                detailCell?.selectionStyle = .none
            }
            detailCell?.textLabel?.text = NSLocalizedString("No data loaded", comment:  "Placeholder label")
            return detailCell!
        }
        
        var textCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier)
        if textCell == nil {
            textCell = UITableViewCell(style: .value2, reuseIdentifier: textCellIdentifier)
            textCell?.selectionStyle = .none
        }
        
        switch DetailRow(rawValue: indexPath.row) {
        case .title:
            textCell?.textLabel?.text = NSLocalizedString("Title", comment: "Movie detail title label")
            textCell?.detailTextLabel?.text = presenter.movieTitleText
        case .tagline:
            textCell?.textLabel?.text = NSLocalizedString("Tagline", comment: "Movie detail tagline label")
            textCell?.detailTextLabel?.text = presenter.movieTaglineText
        case .releaseDate:
            textCell?.textLabel?.text = NSLocalizedString("Release Date", comment: "Movie detail release date label")
            textCell?.detailTextLabel?.text = presenter.movieReleaseDateText
        case .runtime:
            textCell?.textLabel?.text = NSLocalizedString("Runtime", comment: "Movie detail runtime label")
            textCell?.detailTextLabel?.text = presenter.movieRuntimeText
        default:
            ()
        }
        
        return textCell!
    }
}

// Note: As of Xcode 11.4, SwiftUI previews doesn't support files in static libraries

