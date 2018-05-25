//
//  AppDelegateExtension.swift
//  Client
//
//  Created by Tim Palade on 5/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

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
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: InstallDateKey)
                UserDefaults.standard.synchronize()
            }
        }
    }
}
