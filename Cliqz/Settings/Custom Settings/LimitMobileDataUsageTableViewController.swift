//
//  LimitMobileDataUsageTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/15/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class LimitMobileDataUsageTableViewController: ToggleSubSettingsTableViewController {
    
    // MARK:- Abstract methods Implementation
    override func getViewName() -> String {
        return "limit_mobile_data_usage"
    }
    
    override func getToggles() -> [Bool] {
        return [SettingsPrefs.shared.getLimitMobileDataUsagePref()]
    }
    
    override func getToggleTitles() -> [String] {
        return [self.title ?? ""]
    }
    
    override func getSectionFooters() -> [String] {
        return [NSLocalizedString("Download videos on Wi-Fi Only", tableName: "Cliqz", comment: "[Settings -> Limit Mobile Data Usage] toogle footer")]
    }
    
    override func saveToggles(isOn: Bool, atIndex: Int) {
        SettingsPrefs.shared.updateLimitMobileDataUsagePref(isOn)
    }
    
}
