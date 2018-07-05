//
//  CliqzStrings.swift
//  Client
//
//  Created by Tim Palade on 5/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

struct CliqzStrings {}

// Onboarding
extension CliqzStrings {
    public struct Onboarding {
        public var telemetryText: String {
            return NSLocalizedString("Support Ghostery by sharing anonymous analytics and Human Web data to improve Ghostery's performance.", tableName: "Cliqz", comment: "[Onboarding] Telemetry")
        }
        
        public var introText: String {
            return NSLocalizedString("Keep your browsing cleaner, faster, and safer.", tableName: "Cliqz", comment: "[Onboarding] Intro Text")
        }
        public var introTextOldUsers: String {
            return NSLocalizedString("Keep your browsing cleaner, faster and safer. Don't worry, all your data will be imported.", tableName: "Cliqz", comment: "[Onboarding] Intro Text Old Users")
        }
        public var introTitle: String {
            return NSLocalizedString("Introducing Ghostery", tableName: "Cliqz", comment: "[Onboarding] Intro Title")
        }
        public var introTitleOldUsers: String {
            return NSLocalizedString("Introducing New Ghostery", tableName: "Cliqz", comment: "[Onboarding] Intro Title Old Users")
        }
        
        public var adblockerText: String {
            return NSLocalizedString("Browse faster, safer and efficiently with Ad & Tracker Blocking. You can customize your settings in the Ghostery Control Center.", tableName: "Cliqz", comment: "[Onboarding] Adblocker Text")
        }
        public var adblockerTitle: String {
            return NSLocalizedString("Ad & Tracker Blocking", tableName: "Cliqz", comment: "[Onboarding] Adblocker Title")
        }
        
        public var quickSearchText: String {
            return NSLocalizedString("Save time and data volume: Quick Search instantly shows relevant results while typing.", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Text")
        }
        public var quickSearchTitle: String {
            return NSLocalizedString("Quick Search", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Title")
        }
        
        public var tabText: String {
            return NSLocalizedString("Every new Tab comes with top sites, news and background image. Customize it to your needs.", tableName: "Cliqz", comment: "[Onboarding] Tab Text")
        }
        public var tabTitle: String {
            return NSLocalizedString("Ghostery Tab", tableName: "Cliqz", comment: "[Onboarding] Tab Title")
        }
    }
}
