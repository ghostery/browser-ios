//
//  UserPreferences.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/8/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//
import Foundation

@objc open class UserPreferences : NSObject {
    
    enum BlockingMode: Int {
        case none = 0
        case selected = 1
        case all = 2
    }
    
    static let instance = UserPreferences()
    
    let TrackerListVersionKey = "TrackerListVersion"
    let BlockingModeKey = "BlockingMode"
    //let BlockingEnabledKey = "BlockingEnabled"
    let BlockNewTrackersKey = "block_new_trackers_by_default"
    let HasRunBeforeKey = "NotFirstRun"
    let CrashlyticsEnabledKey = "CrashlyticsEnabled"
    
    var blockingMode: BlockingMode {
        get {
            if let mode = BlockingMode(rawValue: userDefaults().integer(forKey: BlockingModeKey)) {
                return mode
            }
            else {
                return .none
            }
        }
        set {
            userDefaults().set(newValue.rawValue, forKey: BlockingModeKey)
        }
    }
    
    func userDefaults() -> UserDefaults {
        return UserDefaults.standard
    }
    
    func writeToDisk() {
        userDefaults().synchronize()
    }
    
    func getBool(_ key: String) -> Bool {
        return userDefaults().bool(forKey: key)
    }
    
    func setBool(_ value: Bool, forKey: String) {
        userDefaults().set(value, forKey: forKey)
    }
    
    func getValueForKey(_ key: String) -> String {
        if let value = userDefaults().value(forKey: key) as? String {
            return value
        }
        
        return ""
    }
    
    func setValueForKey(_ value: String, key: String) {
        userDefaults().setValue(value, forKey: key)
    }
    
    func trackerListVersion() -> Int {
        return userDefaults().integer(forKey: TrackerListVersionKey)
    }
    
    func setTrackerListVersion(_ value: NSNumber) {
        userDefaults().set(value.intValue, forKey: TrackerListVersionKey)
    }
    
    /*func setIsBlockingEnabled(value: Bool) {
     userDefaults().setBool(value, forKey: IsBlockingEnabledKey)
     }
     
     func isBlockingEnabled() -> Bool {
     return userDefaults().boolForKey(IsBlockingEnabledKey)
     }*/
    
    func setAreNewTrackersBlocked(_ value: Bool) {
        userDefaults().set(value, forKey: BlockNewTrackersKey)
    }
    
    func areNewTrackersBlocked() -> Bool {
        return userDefaults().bool(forKey: BlockNewTrackersKey)
    }
    
    func setHasAppRunBefore(_ value: Bool) {
        userDefaults().set(value, forKey: HasRunBeforeKey)
    }
    
    func hasAppRunBefore() -> Bool {
        return userDefaults().bool(forKey: HasRunBeforeKey)
    }
}
