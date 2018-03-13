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

