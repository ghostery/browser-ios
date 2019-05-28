//
//  AppStatus.swift
//  Client
//
//  Created by Mahmoud Adam on 11/12/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation

class AppStatus {
    #if PAID
    static let AppId = "1444118792"
    #elseif GHOSTERY
    static let AppId = "472789016"
    #else
    static let AppId = "1065837334"
    #endif
    
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
    
    class func distVersion() -> String {
        let versionDescriptor = AppStatus.getVersionDescriptor()
        return "\(versionDescriptor.version.trim()) (\(versionDescriptor.commitHash ?? versionDescriptor.buildNumber))"
    }
    
    class func extensionVersion() -> String {
        
        if let path = Bundle.main.path(forResource: "cliqz", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) as Data,
            let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
            
            if let extensionVersion : String = jsonResult["EXTENSION_VERSION"] as? String {
                return extensionVersion
            }
        }
        return ""
    }
    
    fileprivate class func getVersionDescriptor() -> (version: String, buildNumber: String, commitHash: String?) {
        
        var version = "0"
        var buildNumber = "0"
        
        if let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = shortVersion
        }
        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = bundleVersion
        }
        let commitHash = Bundle.main.infoDictionary?["CommitHash"] as? String
        
        return (version, buildNumber, commitHash)
    }
}
