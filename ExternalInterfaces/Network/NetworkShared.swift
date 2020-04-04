//
//  NetworkShared.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 11/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation


class NetworkSubsystem {
    
    let subsystemQueue = DispatchQueue(label: "network-shared", autoreleaseFrequency: .workItem)
    
    static let defaultInstance = NetworkSubsystem()
}
