//
//  ArrayExtensions.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension Array {
    
    public func groupBy<B:Hashable>(key: (Element) -> B) -> Dictionary<B, [Element]>{
        var dict: Dictionary<B, [Element]> = [:]
        
        for elem in self {
            let key = key(elem)
            if var dict_array = dict[key] {
                dict_array.append(elem)
                dict[key] = dict_array
            }
            else {
                dict[key] = [elem]
            }
        }
        
        return dict
    }
    
    public func groupAndReduce<B:Hashable, C>(byKey: (Element) -> B, reduce: ([Element]) -> C) -> Dictionary<B, C> {
        let dict = self.groupBy(key: byKey)
        var reduceDict: Dictionary<B,C> = [:]
        
        for key in dict.keys {
            reduceDict[key] = reduce(dict[key]!)
        }
        
        return reduceDict
    }
}

