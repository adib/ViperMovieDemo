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

class MovieBrowserWireframeImp: MovieBrowserWireframe {

    let dataProvider: MovieDataProvider

    
    init(dataProvider: MovieDataProvider) {
        self.dataProvider = dataProvider
    }
    

    // MARK: MovieBrowserWireframe
    
    func makeInitialRootViewController() -> UIViewController {
        let discoverCtrl =  DiscoverMoviesViewControllerImp()
        let interactor = makeListMoviesInteractor()
        interactor.dataStore = MovieDataAdapter(dataSource: dataProvider)
        discoverCtrl.presenter = MovieListPresenterImp(wireframe: self, interactor: interactor)
        let navCtrl = UINavigationController(rootViewController: discoverCtrl)
        return navCtrl
    }
    
    func present(movieDetail: MovieDetailPresenter, from: UIViewController) {
        print("TODO: present detail for \(movieDetail)")
    }

}
