//
//  DiscoverMoviesWireframeImp.swift
//  InterfaceAdapters
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import UIKit
import DomainEntities
import BusinessLogic

class MovieBrowserWireframeImp: MovieBrowserWireframe, UISplitViewControllerDelegate {
    
    let dataProvider: MovieDataProvider

    weak var _splitViewController: UISplitViewController?
    
    init(dataProvider: MovieDataProvider) {
        self.dataProvider = dataProvider
    }
    
    func fixupNavItem(splitViewController: UISplitViewController) {
        guard   let detailNavController = splitViewController.viewControllers.last as? UINavigationController,
                let topNavItem = detailNavController.topViewController?.navigationItem else {
            return
        }
        topNavItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        topNavItem.leftItemsSupplementBackButton = true
    }
    

    // MARK: - MovieBrowserWireframe

    var rootViewController: UIViewController {
        get {
            if let splitViewController = _splitViewController {
                return splitViewController
            }
            
            let interactor = makeListMoviesInteractor()
            interactor.dataStore = MovieDataAdapter(dataSource: dataProvider)
            let discoverCtrl =  DiscoverMoviesViewControllerImp()
            discoverCtrl.presenter = MovieListPresenterImp(wireframe: self, interactor: interactor)

            let blankDetailCtrl = BlankDetailViewControllerImp()

            let masterNavController = UINavigationController(rootViewController: discoverCtrl)
            let detailNavController = UINavigationController(rootViewController: blankDetailCtrl)

            let splitViewController = UISplitViewController()
            _splitViewController = splitViewController
            splitViewController.viewControllers = [
                masterNavController,
                detailNavController
            ]
            splitViewController.delegate = self
            
            fixupNavItem(splitViewController: splitViewController)
            return splitViewController
        }
    }

    func present(movieDetail: MovieDetailPresenter, from sourceVC: UIViewController) {
        let detailCtrl = MovieDetailViewControllerImp()
        detailCtrl.presenter = movieDetail
        sourceVC.showDetailViewController(detailCtrl, sender: sourceVC)
    }

    // MARK: - UISplitViewControllerDelegate

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else {
            return false
            
        }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else {
            return false
        }
        if topAsDetailController.isEmpty {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        guard   let masterNavCtrl = splitViewController.viewControllers.first as? UINavigationController,
            let detailNavCtrl = splitViewController.viewControllers.last as? UINavigationController else {
                return false
        }
        
        if splitViewController.traitCollection.horizontalSizeClass == .compact {
            masterNavCtrl.pushViewController(vc, animated: true)
        } else {
            detailNavCtrl.viewControllers = [vc]
            fixupNavItem(splitViewController: splitViewController)
        }
        return true
    }
}
