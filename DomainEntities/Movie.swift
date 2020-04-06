//
//  Movie.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 9/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation

public protocol Movie {
    var movieID: MovieIdentifier { get }

}


public protocol MovieSummary: Movie {
    var originalTitle: String? { get }
    var originalLanguage: String? { get }
    var releaseDate: DateComponents? { get  }
}


public protocol MovieIdentifier: AnyEquatable {
    
}


public protocol MovieDetail: MovieSummary {
    var tagline: String? { get }
    var runtime: TimeInterval? { get }
}


public protocol AnyEquatable {
    func isEqual(_ object: Any?) -> Bool
}


public extension AnyEquatable where Self: Equatable {
   func isEqual (_ rhs: Any?) -> Bool {
        return self == (rhs as? Self)
    }
}
