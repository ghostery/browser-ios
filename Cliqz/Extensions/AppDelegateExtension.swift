//
//  AppDelegateExtension.swift
//  Client
//
//  Created by Tim Palade on 5/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import NetworkExtension

let InstallDateKey = "InstallDateKey"
#if GHOSTERY
let HasRunBeforeKey = "previous_version"
#endif
extension AppDelegate {
    func recordInstallDateIfNecessary() {
        guard let profile = self.profile else { return }
        if profile.prefs.stringForKey(LatestAppVersionProfileKey)?.components(separatedBy: ".").first == nil {
            // Clean install, record install date
            if UserDefaults.standard.value(forKey: InstallDateKey) == nil {
                //Avoid overrides
                LocalDataStore.set(value: Date().timeIntervalSince1970, forKey: InstallDateKey)
            }
        }
    }
    
    func customizeNnavigationBarAppearace() {
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.barTintColor = UIColor.cliqzBluePrimary
        navigationBarAppearace.isTranslucent = false
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
}
