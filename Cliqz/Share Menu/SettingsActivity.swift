//
//  SettingsActivity.swift
//  Client
//
//  Created by Mahmoud Adam on 4/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

let ShowSettingsNotification = NSNotification.Name(rawValue: "ShareMenu.ShowSettings")

class SettingsActivity : UIActivity {
    
    override var activityTitle : String? {
        return NSLocalizedString("Settings", tableName: "Cliqz", comment: "Sharing activity for opening Settings")
    }
    
    override var activityImage : UIImage? {
        return UIImage(named: "settings")
    }
    
    override var activityType: UIActivityType? {
        return UIActivityType("com.cliqz.settings")
    }
    
    override func perform() {
        NotificationCenter.default.post(name: ShowSettingsNotification, object: nil)
        activityDidFinish(true)
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
}

