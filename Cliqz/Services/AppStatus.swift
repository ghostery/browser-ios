//
//  AppStatus.swift
//  Client
//
//  Created by Mahmoud Adam on 11/12/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation

class AppStatus {
    
    class func isRelease() -> Bool {
        #if BETA
            return false
        #else
            return true
        #endif
    }
    
    class func isDebug() -> Bool {
        return _isDebugAssertConfiguration()
    }
    
}
