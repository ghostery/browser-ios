//
//  AppMigrationManager.swift
//  Client
//
//  Created by Pavel Kirakosyan on 23.07.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Shared

private let initialVersion = "1.0.0"
private let applicationVersion_1_0_7 = "1.0.7"
private let applicationVersionKey = "applicationVersionKey"

/*
 * @brief - responsible for application logic migration from version to version
 */
class AppMigrationManager {
    let profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    var userDefaults: UserDefaults {
        return UserDefaults.standard
    }

    func migrateIfNeeded() {
        let currentVersion : String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

        var oldVersion = self.userDefaults.value(forKey: applicationVersionKey) as? String
        if oldVersion == nil {
            let isFirstLaunch = profile.prefs.intForKey(PrefsKeys.IntroSeen) == nil
            oldVersion = isFirstLaunch ? nil : initialVersion
        }

        if oldVersion != currentVersion {
            self.migrate(from: oldVersion, to: currentVersion)
            self.userDefaults.setValue(currentVersion, forKey: applicationVersionKey)
            self.userDefaults.synchronize()
        }

    }

    private func migrate(from: String?, to: String) {
        if from == nil { // means new fresh installation
            UserPreferences.instance.showSearchOnboarding = false
        } else if from == initialVersion { // means lower then 1.0.7
            UserPreferences.instance.showSearchOnboarding = true
            let defaultSearch = profile.searchEngines.defaultEngine
            profile.searchEngines.defaultEngine = defaultSearch
        } else {
            print("Migrating from version \(from!) to \(to)")
        }
    }
}
