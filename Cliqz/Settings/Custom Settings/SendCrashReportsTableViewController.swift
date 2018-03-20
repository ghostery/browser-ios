//
//  SendCrashReportsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/20/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class SendCrashReportsTableViewController: ToggleSubSettingsTableViewController {
    // MARK:- Abstract methods Implementation
    override func getViewName() -> String {
        return "crash_reports"
    }
    
    override func getToggles() -> [Bool] {
        return [SettingsPrefs.shared.getAutoForgetTabPref()]
    }
    
    override func getToggleTitles() -> [String] {
        return [self.title ?? ""]
    }
    
    override func getSectionFooters() -> [String] {
        return [NSLocalizedString("We use opensource software Sentry (http://sentry.io) for our crash reports. these reports do not contain any personal data.", tableName: "Cliqz", comment: "[Settings -> Send Crash Reports] Footer text")]
    }
    
    override func saveToggles(isOn: Bool, atIndex: Int) {
        SettingsPrefs.shared.updateSendCrashReportsPref(isOn)
    }
}
