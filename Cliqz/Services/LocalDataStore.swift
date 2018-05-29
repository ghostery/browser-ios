//
//  LocalDataStore.swift
//  Client
//
//  Created by Mahmoud Adam on 11/9/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation

class LocalDataStore {
    static let defaults = UserDefaults.standard

    class func set(value: Any?, forKey: String) {
        defaults.set(value, forKey: forKey)
        defaults.synchronize()
    }
    
    class func value(forKey: String) -> Any? {
        return defaults.value(forKey: forKey) as Any?
    }
    
    class func removeObject(forKey: String) {
        defaults.removeObject(forKey: forKey)
        defaults.synchronize()
    }
}
