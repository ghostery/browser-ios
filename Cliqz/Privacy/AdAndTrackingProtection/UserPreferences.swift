//
//  UserPreferences.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/8/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//
import Foundation
import Storage

#if PAID
extension Notification.Name {
    static let privacyStatusChanged = Notification.Name("BlockedTrackerSetChangedNotification")
}
#endif

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
    
    public override init() {
        super.init()
        #if !PAID
        NotificationCenter.default.addObserver(self, selector: #selector(updateAntitrackingPref), name: Notification.Name.BlockedTrackerSetChanged, object: nil)
        #endif
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    let TrackerListVersionKey = "TrackerListVersion"
    let AntitrackingModeKey = "AntitrackingMode"
    let AdblockingModeKey = "AdblockingMode"
    let PrevAdblockingModeKey = "PreviousAdblockingMode"
    let PauseGhosteryDateKey = "PauseGhosteryDate"

    let IsDeveloperModeOnKey = "IsDeveloperModeOnKey"
    let ShowPromoCodeKey = "ShowPromoCodeKey"
    let ShowNonPrivateSearchWarningKey = "ShowPromoCodeKey"

    /// If `true`, send a `developer` flag in the telemetry data.
    ///
    /// Activate devloper mode by going to Settings -> About and perform a two finger long press gesture to show the advanced options.
    ///
    /// @see https://cliqztix.atlassian.net/browse/IP-550
    var isDeveloperModeOn: Bool {
        get {
            if let val = userDefaults().value(forKey: IsDeveloperModeOnKey) as? Bool {
                return val
            }

            return false
        }
        set {
            userDefaults().set(newValue, forKey: IsDeveloperModeOnKey)
            Engine.sharedInstance.setPref("developer", prefValue: newValue)
        }
    }
    
    var shouldShowPromoCode: Bool {
        get {
            if let val = userDefaults().value(forKey: ShowPromoCodeKey) as? Bool {
                return val
            }
            
            return false
        }
        set {
            userDefaults().set(newValue, forKey: ShowPromoCodeKey)
        }
    }

    var shouldShowNonPrivateSearchWarningMessage: Bool {
        get {
            if let val = userDefaults().value(forKey: ShowNonPrivateSearchWarningKey) as? Bool {
                return val
            }

            return true
        }
        set {
            userDefaults().set(newValue, forKey: ShowNonPrivateSearchWarningKey)
        }
    }
    
    #if PAID
    let IsProtectionOnKey = "IsProtectionOnKey"
    
    var isProtectionOn: Bool {
        get {
            if let val = userDefaults().value(forKey: IsProtectionOnKey) as? Bool {
                return val
            }
            
            return true
        }
        set {
            userDefaults().set(newValue, forKey: IsProtectionOnKey)
            Engine.sharedInstance.setPref("lumen.protection.isEnabled", prefValue: newValue)
            NotificationCenter.default.post(name: Notification.Name.privacyStatusChanged, object: self, userInfo: ["newValue": newValue])
        }
    }
    
    #else
    
    @objc func updateAntitrackingPref(_ sender: Any?) {
        if TrackerStateStore.shared.blockedTrackers.count == TrackerList.instance.appsList.count, self._antitrackingMode != .blockAll {
            self._antitrackingMode = .blockAll
            self.writeToDisk()
        }
        else if TrackerStateStore.shared.blockedTrackers.count != TrackerList.instance.appsList.count, self.antitrackingMode != .blockSomeOrNone {
            self._antitrackingMode = .blockSomeOrNone
            self.writeToDisk()
        }
    }
    
    // antitracking mode is supposed to be set only in updateAntitrackingPref. It depends on the number of trackers blocked.
    var antitrackingMode: AntitrackingMode {
        get {
            return _antitrackingMode
        }
        
        set {
            //don't set
        }
    }
    
    private var _antitrackingMode: AntitrackingMode {
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
            if let mode = userDefaults().object(forKey: AdblockingModeKey) as? Int,
                let blockingMode = AdblockingMode(rawValue: mode) {
                return blockingMode
            }
            else {
                return .blockAll
            }
        }
        set {
            prevAdblockingMode = adblockingMode
            userDefaults().set(newValue.rawValue, forKey: AdblockingModeKey)
        }
    }
    
    var prevAdblockingMode: AdblockingMode {
        get {
            if let mode = userDefaults().object(forKey: PrevAdblockingModeKey) as? Int,
                let blockingMode = AdblockingMode(rawValue: mode) {
                return blockingMode
            }
            else {
                return .blockAll
            }
        }
        set {
            userDefaults().set(newValue.rawValue, forKey: PrevAdblockingModeKey)
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
    
    #endif
    
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
}
