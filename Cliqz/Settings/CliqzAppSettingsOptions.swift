//
//  CliqzAppSettingsOptions.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

// MARK:- cliqz settings
class HumanWebSetting: CliqzOnOffSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Human Web", tableName: "Cliqz", comment: "[Settings] Human Web")
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getHumanWebPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return HumanWebSettingsTableViewController()
    }
}


class AutoForgetTabSetting: CliqzOnOffSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Automatic Forget Tab", tableName: "Cliqz", comment: " [Settings] Automatic Forget Tab")
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getAutoForgetTabPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return AutoForgetTabTableViewController()
    }
    
}


class LimitMobileDataUsageSetting: CliqzOnOffSetting {
    override func getTitle() -> String {
        return NSLocalizedString("Limit Mobile Data Usage", tableName: "Cliqz", comment: "[Settings] Limit Mobile Data Usage")
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getLimitMobileDataUsagePref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return LimitMobileDataUsageTableViewController()
    }
    
}

