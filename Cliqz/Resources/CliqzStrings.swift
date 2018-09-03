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
            return NSLocalizedString("Browse cleaner, faster, and safer on-the-go with Ghostery, now optimized for mobile!", tableName: "Cliqz", comment: "[Onboarding] Intro Text")
        }
        
        public var introTextOldUsers: String {
            return NSLocalizedString("Browse cleaner, faster, and safer on-the-go with Ghostery, now optimized for mobile! Don't worry, all your data will be imported.", tableName: "Cliqz", comment: "[Onboarding] Intro Text Old Users")
        }
        public var introTitle: String {
            return NSLocalizedString("Introducing Ghostery", tableName: "Cliqz", comment: "[Onboarding] Intro Title")
        }
        public var introTitleOldUsers: String {
            return NSLocalizedString("Introducing New Ghostery", tableName: "Cliqz", comment: "[Onboarding] Intro Title Old Users")
        }
        
        public var adblockerText: String {
            return NSLocalizedString("Choose what you want Ghostery to block for cleaner, faster, and safer browsing. You can change and customize these settings at any time in the Privacy Control Center.", tableName: "Cliqz", comment: "[Onboarding] Adblocker Text")
        }
        public var adblockerTitle: String {
            return NSLocalizedString("Ad & Tracker Blocking", tableName: "Cliqz", comment: "[Onboarding] Adblocker Title")
        }
        
        public var quickSearchText: String {
            return NSLocalizedString("Stay anonymous, reduce data usage, and save time: results appear instantly as you type in the Ghost search bar.", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Text")
        }
        public var quickSearchTitle: String {
            return NSLocalizedString("Ghost Search", tableName: "Cliqz", comment: "[Onboarding] QuickSearch Title")
        }
        
        public var tabText: String {
            return NSLocalizedString("Each new Start Tab is customizable and can display top sites, the latest news, and other tracking insights to come.", tableName: "Cliqz", comment: "[Onboarding] Tab Text")
        }
        public var tabTitle: String {
            return NSLocalizedString("Start Tab", tableName: "Cliqz", comment: "[Onboarding] Freshtab Title")
        }
    }
}
