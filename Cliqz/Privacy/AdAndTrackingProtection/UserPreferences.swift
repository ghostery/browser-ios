//
//  UserPreferences.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/8/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//
import Foundation

@objc open class UserPreferences : NSObject {
    
    enum AntitrackingMode: Int {
        case blockSomeOrNone = 0 //something or nothing
        case blockAll = 1
    }
    
    enum AdblockingMode: Int {
        case blockNone = 0
        case blockAll = 1
    }
    
    enum PauseGhosteryMode: Int {
        case notPaused = 0
        case paused = 1
    }
    
    static let instance = UserPreferences()
    
    let TrackerListVersionKey = "TrackerListVersion"
    let AntitrackingModeKey = "AntitrackingMode"
    let AdblockingModeKey = "AdblockingMode"
    let PauseGhosteryDateKey = "PauseGhosteryDate"
    let BlockNewTrackersKey = "block_new_trackers_by_default"
    let HasRunBeforeKey = "NotFirstRun"
    
    var antitrackingMode: AntitrackingMode {
        get {
            if let mode = AntitrackingMode(rawValue: userDefaults().integer(forKey: AntitrackingModeKey)) {
                return mode
            }
            else {
                return .blockSomeOrNone
            }
        }
        set {
            userDefaults().set(newValue.rawValue, forKey: AntitrackingModeKey)
        }
    }
    
    var adblockingMode: AdblockingMode {
        get {
            if let mode = AdblockingMode(rawValue: userDefaults().integer(forKey: AdblockingModeKey)) {
                return mode
            }
            else {
                return .blockNone
            }
        }
        set {
            userDefaults().set(newValue.rawValue, forKey: AdblockingModeKey)
        }
    }
    
    var pauseGhosteryMode: PauseGhosteryMode {
        get {
            if Date().timeIntervalSince1970 < pauseGhosteryDate.timeIntervalSince1970 {
                return .paused
            }
            return .notPaused
        }
        set {
            fatalError("never set the ghostery mode")
        }
    }
    
    var pauseGhosteryDate: Date {
        get {
            let interval = userDefaults().double(forKey: PauseGhosteryDateKey)
            return Date(timeIntervalSince1970: interval)
        }
        set {
            userDefaults().set(newValue.timeIntervalSince1970, forKey: PauseGhosteryDateKey)
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
