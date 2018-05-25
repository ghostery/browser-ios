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
        public static let telemetryText = NSLocalizedString("Support Ghostery by sharing anonymous analytics and Human Web data to improve Ghostery's performance.", tableName: "Cliqz", comment: "[Onboarding] Telemetry")
        public static let introText = NSLocalizedString("Keep your browsing cleaner, faster, and safer. By using this app you agree to the Privacy Policy.", tableName: "Cliqz", comment: "[Onboarding] Intro Text")
        public static let introTitle = NSLocalizedString("Introducing Ghostery", tableName: "Cliqz", comment: "[Onboarding] Intro Title")
        
        public static let adblockerText = NSLocalizedString("Browse faster, safer and efficiently with Ad & Tracker Blocking. You can customize your settings in the Ghostery Control Center.", tableName: "Cliqz", comment: "[Onboarding] Adblocker Text")
        public static let adblockerTitle = NSLocalizedString("Ad & Tracker Blocking", tableName: "Cliqz", comment: "[Onboarding] Adblocker Title")
        
        public static let quickSearchText = NSLocalizedString("Save time and data volume: Quick Search instantly shows relevant results while typing.", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Text")
        public static let quickSearchTitle = NSLocalizedString("Quick Search", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Title")
        
        public static let tabText = NSLocalizedString("Every new Tab comes with top sites, news and background image. Customize it to your needs.", tableName: "Cliqz", comment: "[Onboarding] Tab Text")
        public static let tabTitle = NSLocalizedString("Ghostery Tab", tableName: "Cliqz", comment: "[Onboarding] Tab Title")
    }
}
