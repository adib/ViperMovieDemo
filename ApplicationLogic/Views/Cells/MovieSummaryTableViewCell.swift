//
//  MovieOverviewTableViewCell.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit
import DomainEntities

class MovieSummaryTableViewCell: UITableViewCell, MovieSummaryCell {
    
    override func prepareForReuse() {
        movieID = nil
        super.prepareForReuse()
    }
    
    // MARK: - MovieSummaryPresenterOutput
    
    var movieID: MovieIdentifier?
    
    func setMovieOriginalTitle(_ title: String?) {
        self.textLabel?.text = title
    }

}
