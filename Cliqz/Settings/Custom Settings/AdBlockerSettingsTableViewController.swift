//
//  AdBlockerSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/15/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class AdBlockerSettingsTableViewController: ToggleSubSettingsTableViewController {
    // MARK:- Abstract methods Implementation
    override func getViewName() -> String {
        return "block_ads"
    }
    
    override func getToggles() -> [Bool] {
        return [SettingsPrefs.shared.getAdBlockerPref(), SettingsPrefs.shared.getFairBlockingPref()]
    }
    
    override func getToggleTitles() -> [String] {
        return [NSLocalizedString("Block Ads", tableName: "Cliqz", comment: "[Settings -> Block Ads] Block Ads"),
                NSLocalizedString("Fair Mode", tableName: "Cliqz", comment: "[Settings -> Block Ads] Fair Mode")]
    }
    
    override func getSectionFooters() -> [String] {
        return [NSLocalizedString("Cliqz Browser has to download some data packages first, before the ad-blocker works efficiently. For this, the app must be connected to Wi-Fi.", tableName: "Cliqz", comment: "[Settings -> Block Ads] Block Ads footer"),
                NSLocalizedString("A \"fair\" mode that shows ads in clearly defined cases only will be added soon.", tableName: "Cliqz", comment: "[Settings -> Block Ads] Fair Mode footer")]
    }
    
    override func saveToggles(isOn: Bool, atIndex index: Int) {
        index == 0 ? SettingsPrefs.shared.updateAdBlockerPref(isOn) : SettingsPrefs.shared.updateFairBlockingPref(isOn)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.getToggles()[0] {
            return 2
        }
        return 1
    }
}
