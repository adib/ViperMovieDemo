//
//  AppLogicShared.swift
//  ApplicationLogic
//
//  Created by Sasmito Adibowo on 6/4/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation


class AppLogicSubsystem {
    
    let subsystemQueue = DispatchQueue(label: "appLogic-shared", autoreleaseFrequency: .workItem)

    static let defaultInstance = AppLogicSubsystem()
}
