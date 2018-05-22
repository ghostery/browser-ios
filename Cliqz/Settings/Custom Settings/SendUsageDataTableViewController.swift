//
//  SendUsageDataTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 5/22/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class SendUsageDataTableViewController: ToggleSubSettingsTableViewController {
    // MARK:- Abstract methods Implementation
    override func getViewName() -> String {
        return "crash_reports"
    }
    
    override func getToggles() -> [Bool] {
        return [SettingsPrefs.shared.getSendUsageDataPref()]
    }
    
    override func getToggleTitles() -> [String] {
        return [self.title ?? ""]
    }
    
    override func getSectionFooters() -> [String] {
        return [NSLocalizedString("Help us improve your browsing experience. Cliqz collects strictly anonymous usage data. At no occasion is any PII collected. Learn more at http://cliqz.com/en/privacy-browser.", tableName: "Cliqz", comment: "[Settings -> Send Telemetry] Footer text")]
    }
    
    override func saveToggles(isOn: Bool, atIndex: Int) {
        SettingsPrefs.shared.updateSendUsageDataPref(isOn)
    }
}
