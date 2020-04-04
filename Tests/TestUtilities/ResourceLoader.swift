//
//  ResourceLoader.swift
//  NestedCollectionViewDemoTests
//
//  Created by Sasmito Adibowo on 13/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func findTestResource(name: String, withExtension ext: String) -> URL {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            XCTFail("Cannot find resource named \(name).\(ext)")
            abort()
        }
        return url
    }
}
