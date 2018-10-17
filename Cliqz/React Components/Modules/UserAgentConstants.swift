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
            let product = getProductType()
            let type = getChannelType()
            return "MI\(product)\(type)"
        }
    }
    
    fileprivate var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    fileprivate var installDate: String {
        // Original install date (not migration day from ghostery/old cliqz browser)
        // Format: Days since Epoch
        #if GHOSTERY
        if let _ = UserDefaults.standard.value(forKey: HasRunBeforeKey) as? String {
            //this is an old ghostery user
            return "16917";
        }
        else {
            let installDate: Date
            if let installDateTime = LocalDataStore.value(forKey: InstallDateKey) as? Double {
                installDate = Date(timeIntervalSince1970: installDateTime)
            }
            else {
                installDate = Date()
                //register the install date
                LocalDataStore.set(value: installDate.timeIntervalSince1970, forKey: InstallDateKey)
            }
            return String(installDate.daysSince1970())
        }
        #endif
        //return "16917";
    }

    private func getProductType() -> String {
        #if AUTOMATION
        return "9"
        #elseif GHOSTERY
        return "5"
        #elseif PAID
        return "6"
        #else
        return "0"
        #endif
    }
    
    private func getChannelType() -> String {
        #if RELEASE
        return "0"
        #elseif BETA
        return "1"
        #elseif AUTOMATION
        return "9"
        #else
        return "2"
        #endif
    }

    static var appName: String {
        #if GHOSTERY
            return "Ghostery"
        #else
            return "Cliqz"
        #endif
    }
    
    static var storeURL: URL? {
        #if GHOSTERY
        return URL(string:"https://itunes.apple.com/de/app/ghostery/id472789016?mt=8")
        #else
        return URL(string:"https://itunes.apple.com/de/app/cliqz-browser/id1065837334?mt=8")
        #endif
    }
    open override static func moduleName() -> String! {
        return "UserAgentConstants"
    }
    
    override open func constantsToExport() -> [AnyHashable : Any]! {
        return ["channel": self.source, "appVersion": self.appVersion, "installDate": self.installDate, "appName": UserAgentConstants.appName]
    }
    
}
