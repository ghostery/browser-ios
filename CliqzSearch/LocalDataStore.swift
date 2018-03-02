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
    
    // wrtiting operation is done on Main thread because of a bug in FireFox that it is changing UI when any change is done to user defaults
    static let dispatchQueue = DispatchQueue.main

    class func setObject(_ value: Any?, forKey: String) {
        dispatchQueue.async {
            defaults.set(value, forKey: forKey)
            defaults.synchronize()
        }
    }
    
    class func objectForKey(_ key: String) -> Any? {
        return defaults.object(forKey: key) as Any?
    }
    
    class func removeObjectForKey(_ key: String) {
        dispatchQueue.async {
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }
    }
}
