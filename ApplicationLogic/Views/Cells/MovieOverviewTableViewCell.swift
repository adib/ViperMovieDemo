//
//  MovieOverviewTableViewCell.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit
import DomainEntities

class MovieOverviewTableViewCell: UITableViewCell, MovieSummaryPresenterOutput {
    
    
    var contentCell: MovieCellContentView!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private final func commonInit() {
        let contentView = self.contentView
        let contentFrame = contentView.bounds
        contentCell = MovieCellContentView(frame: contentFrame)
        contentCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.addSubview(contentCell)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        contentCell.prepareForReuse()
        movieID = nil
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }

    
    // MARK: - MovieSummaryPresenterOutput
    
    var movieID: MovieIdentifier?
    
    func setMovieOriginalTitle(_ title: String?) {
        contentCell.titleLabel.text = title
    }

}
