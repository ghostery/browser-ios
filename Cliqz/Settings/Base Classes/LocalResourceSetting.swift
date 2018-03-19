//
//  LocalResourceSetting.swift
//  Client
//
//  Created by Mahmoud Adam on 3/16/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class LocalResourceSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: getTitle(), attributes: [NSForegroundColorAttributeName: SettingsUX.TableViewRowTextColor])
    }
    
    override var url: URL? {
        let (name, module) = getResource()
        return URL(string: WebServer.sharedInstance.URLForResource(name, module: module))
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
        
        // TODO: Telemetry
        /*
         // Cliqz: log telemetry signal
         let licenseSignal = TelemetryLogEventType.Settings("main", "click", "eula", nil, nil)
         TelemetryLogger.sharedInstance.logEvent(licenseSignal)
         */
    }
    
    func getTitle() -> String {
        return ""
    }
    
    func getResource() -> (String, String) {
        return ("", "")
    }
}
