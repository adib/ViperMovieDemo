//
//  Movie.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 9/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation

public protocol Movie {
    var originalTitle: String? { get }
    var originalLanguage: String? { get }
    var releaseDate: DateComponents? { get  }
}


public protocol MovieSummary: Movie {
    var movieID: MovieIdentifier { get }
}


public protocol MovieIdentifier: HasEqual {
    
}



public protocol MovieDetail: MovieSummary {
    var tagline: String? { get }
    
    // TODO: add more properties
}


public protocol MovieImageIdentifier: HasEqual {
    
}


public protocol MovieImage {
    var imageData: Data? { get }
    var mimeType: String? { get }
}


public protocol HasEqual {
    func isEqual(to: HasEqual) -> Bool
}

public extension HasEqual where Self: Equatable {
   func isEqual (to rhs: HasEqual) -> Bool {
        return self == (rhs as? Self)
    }
}
