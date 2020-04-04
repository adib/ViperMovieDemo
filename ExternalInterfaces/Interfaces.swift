//
//  Interfaces.swift
//  Drivers
//
//  Created by Sasmito Adibowo on 15/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation
import ApplicationLogic

public func makeMovieDatabaseClient() -> MovieDataProvider {
    return MovieDatabaseClient()
}
