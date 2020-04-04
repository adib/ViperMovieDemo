//
//  MovieCellContentView.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 8/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

#if DEBUG
import SwiftUI
#endif

class MovieCellContentView: UIView {

    var titleLabel: UILabel!
    
    private var imageThumbnailCollectionView: UICollectionView!
    private var imageThumbnailHandler: ImageThumbnailCollectionViewHandler!

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
        self.translatesAutoresizingMaskIntoConstraints = true
        
        titleLabel = UILabel()

        let imageThumbnailLayout = UICollectionViewFlowLayout()
        //imageThumbnailLayout.scrollDirection = .horizontal
        imageThumbnailLayout.estimatedItemSize = CGSize(width: 80, height: 80)
        imageThumbnailLayout.scrollDirection = .horizontal
        
        imageThumbnailCollectionView = UICollectionView(frame: contentFrame, collectionViewLayout: imageThumbnailLayout)
        imageThumbnailCollectionView.backgroundColor = .green
        
        imageThumbnailHandler = ImageThumbnailCollectionViewHandler(collectionView: imageThumbnailCollectionView)
        
        let mainStack = UIStackView(frame: contentFrame)
        mainStack.axis = .vertical
        mainStack.distribution = .fill
        mainStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainStack.addArrangedSubview(titleLabel)
        mainStack.addArrangedSubview(imageThumbnailCollectionView)

        self.addSubview(mainStack)
        
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }

    func reloadData() {
        imageThumbnailCollectionView.reloadData()
    }
    
    func prepareForReuse() {
        titleLabel.text = nil
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}


class ImageThumbnailCollectionViewHandler: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let movieImageCellIdentifier = "movieImageCell"
    
    init(collectionView: UICollectionView) {
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: movieImageCellIdentifier)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieImageCellIdentifier, for: indexPath) as! MovieImageCollectionViewCell
        
        
//        let cell = MovieImageCellCollectionViewCell()
//        print("cell: \(indexPath)")
        cell.setImage(image: UIImage(systemName: "tortoise.fill")!)
        cell.backgroundColor = .yellow
        return cell
    }
    
    
}



#if DEBUG

struct MovieContentView_Demo: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<MovieContentView_Demo>) -> MovieCellContentView {
        let cell = MovieCellContentView(frame: CGRect(x: 0, y: 0, width: 320, height: 88))
        cell.reloadData()
        return cell
    }
    
    func updateUIView(_ uiView: MovieCellContentView, context: UIViewRepresentableContext<MovieContentView_Demo>) {
       // <#code#>
    }
    
    typealias UIViewType = MovieCellContentView
    
}

struct MovieContentView_Previews : PreviewProvider {
    static var previews: some View {
        MovieContentView_Demo()
    }
}
#endif

