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
        #if PAID
        return [NSLocalizedString("Help us improve your browsing experience. Lumen collects strictly anonymous usage data. At no occasion is any personal data collected.", tableName: "Lumen", comment: "Restore Tabs Prompt Description")]
        #else
        return [NSLocalizedString("Help us improve your browsing experience. Ghostery collects strictly anonymous usage data. At no occasion is any personal data collected.", tableName: "Ghostery", comment: "Restore Tabs Prompt Description")]
        #endif
    }
    
    override func saveToggles(isOn: Bool, atIndex: Int) {
        SettingsPrefs.shared.updateSendUsageDataPref(isOn)
    }
}
