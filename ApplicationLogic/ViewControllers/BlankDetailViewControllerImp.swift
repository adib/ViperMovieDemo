//
//  BlankDetailViewControllerImp.swift
//  ApplicationLogic
//
//  Created by Sasmito Adibowo on 5/4/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit

class BlankDetailViewControllerImp: UIViewController, DetailViewController {
    
    override func loadView() {
        let rootLabel = UILabel()
        rootLabel.text = NSLocalizedString("No item selected.", comment: "Blank placeholder")
        rootLabel.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

        let rootView = UIView(frame: CGRect(x:0, y:0, width:320, height:320))
        rootLabel.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(rootLabel)
        rootView.addConstraint(.init(item: rootLabel, attribute: .centerX, relatedBy: .equal, toItem: rootView, attribute: .centerX, multiplier: 1, constant: 0))
        rootView.addConstraint(.init(item: rootLabel, attribute: .centerY, relatedBy: .equal, toItem: rootView, attribute: .centerY, multiplier: 1, constant: 0))
        rootView.backgroundColor = .tertiarySystemBackground
        self.view = rootView
    }
    
    // MARK: - DetailViewController
    var isEmpty: Bool {
        get {
            true
        }
    }

}
