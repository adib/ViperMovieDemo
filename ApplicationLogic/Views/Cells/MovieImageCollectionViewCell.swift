//
//  MovieImageCellCollectionViewCell.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

class MovieImageCollectionViewCell: UICollectionViewCell {
    
    private var mainImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private final func commonInit() {
        let contentFrame = self.bounds
        mainImageView = UIImageView(frame: contentFrame)
        mainImageView.isOpaque = true
        mainImageView.contentMode = .scaleAspectFit
        mainImageView.autoresizingMask = [.flexibleWidth, .flexibleWidth]
        self.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(mainImageView)
    }
    
    override func prepareForReuse() {
        mainImageView.image = nil
        super.prepareForReuse()
    }

    
    func setImage(image: UIImage) {
        mainImageView.image = image
    }
}
