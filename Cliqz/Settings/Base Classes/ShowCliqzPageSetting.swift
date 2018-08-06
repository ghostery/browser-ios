//
//  ShowCliqzPageSetting.swift
//  Client
//
//  Created by Mahmoud Adam on 3/15/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class ShowCliqzPageSetting: Setting {
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    override var title: NSAttributedString? {
        return NSAttributedString(string: getTitle(), attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor])
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
        
        // TODO: Telemetry
        /*
         // Cliqz: log telemetry signal
         let contactSignal = TelemetryLogEventType.Settings("main", "click", getViewName(), nil, nil)
         TelemetryLogger.sharedInstance.logEvent(contactSignal)
         */
    }
    
    override var url: URL? {
        if let languageCode = Locale.current.regionCode, languageCode == "de"{
            return URL(string: "https://cliqz.com/\(getPageName())")
        }
        return URL(string: "https://cliqz.com/en/\(getPageName())")
    }
    
    func getTitle() -> String {
        return ""
    }
    
    func getPageName() -> String {
        return ""
    }
}
