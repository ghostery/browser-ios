//
//  UserAgentConstants.swift
//  Client
//
//  Created by Sam Macbeth on 10/10/2017.
//  Copyright © 2017 Cliqz GmbH. All rights reserved.
//

import Foundation
import React

@objc(UserAgentConstants)
open class UserAgentConstants : RCTEventEmitter {
    
    fileprivate var source: String {
        get {
            if AppStatus.isDebug() {
                return "MI02" // Debug
            } else if AppStatus.isRelease() {
                return "MI00" // Release
            } else {
                return "MI01" // TestFlight
            }
        }
    }
    
    fileprivate var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    fileprivate var installDate: String {
        // Original install date (not migration day from ghostery/old cliqz browser)
        // Format: Days since Epoch
        return "16917";
    }
    
    open override static func moduleName() -> String! {
        return "UserAgentConstants"
    }
    
    override open func constantsToExport() -> [AnyHashable : Any]! { return ["channel": self.source, "appVersion": self.appVersion, "installDate": self.installDate] }
    
}
