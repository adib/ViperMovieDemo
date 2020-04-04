//
//  GenericResult.swift
//  NestedCollectionViewDemo
//
//  Created by Sasmito Adibowo on 11/3/20.
//  Copyright © 2020 Basil Salad Software. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
    
    public var value: T? {
        get {
            guard case let .success(result) = self else {
                return nil
            }
            return result
        }
    }
    
    public var error: Error? {
        get {
            guard case let .failure(err) = self else {
                return nil
            }
            return err
        }
    }
    
    struct NilChainSource: Error { }
    
    public init(chain: Result<T>?) {
        switch chain {
        case .none:
            self = .failure(NilChainSource())
        case .some(.failure(let err)):
            self = .failure(err)
        case .some(.success(let sourceValue)):
            self = .success(sourceValue)
        }
    }
    
    public init(error: Error?) {
        if let err = error {
            self = .failure(err)
        } else {
            self = .failure(NilChainSource())
        }
    }
}
