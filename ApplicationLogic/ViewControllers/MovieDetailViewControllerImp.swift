//
//  MovieDetailViewControllerImp.swift
//  ApplicationLogic
//
//  Created by Sasmito Adibowo on 5/4/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

class MovieDetailViewControllerImp: UIViewController, DetailViewController, MovieDetailPresenterOutput {
    
    var presenter: MovieDetailPresenter? {
        didSet {
            guard let p = presenter else {
                return
            }
            p.output = self
        }
    }
    
    

    override func loadView() {
        let rootLabel = UILabel()
        rootLabel.text = NSLocalizedString("Movie Detail.", comment: "placeholder")
        rootLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

        let rootView = UIView(frame: CGRect(x:0, y:0, width:320, height:320))
        rootLabel.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(rootLabel)
        rootView.addConstraint(.init(item: rootLabel, attribute: .centerX, relatedBy: .equal, toItem: rootView, attribute: .centerX, multiplier: 1, constant: 0))
        rootView.addConstraint(.init(item: rootLabel, attribute: .centerY, relatedBy: .equal, toItem: rootView, attribute: .centerY, multiplier: 1, constant: 0))
        rootView.backgroundColor = .green
        self.view = rootView
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - DetailViewController
    var isEmpty: Bool {
        get { presenter == nil }
    }

}
