//
//  CliqzOnOffSetting.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class CliqzSettingsConstants {
    static let onStatus = NSLocalizedString("On", tableName: "Cliqz", comment: "[Settings] On status")
    static let offStatus = NSLocalizedString("Off", tableName: "Cliqz", comment: "[Settings] Off status")
}

class CliqzOnOffSetting: Setting {
    let profile: Profile
    override var style: UITableViewCellStyle { return .value1 }
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    init(settings: SettingsTableViewController, title: String) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
    }
    
    override var status: NSAttributedString {
        return NSAttributedString(string: isOn() ? CliqzSettingsConstants.onStatus : CliqzSettingsConstants.offStatus)
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = getSubSettingViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
        
        // TODO: Telemetry
        /*
         // log Telemerty signal
         let humanWebSingal = TelemetryLogEventType.Settings("main", "click", viewController.getViewName(), nil, nil)
         TelemetryLogger.sharedInstance.logEvent(humanWebSingal)
         */
    }
    
    // MARK:- Abbstract methods
    func isOn() -> Bool {
        return false
    }
    
    func getSubSettingViewController() -> SubSettingsTableViewController {
        return SubSettingsTableViewController()
    }
}
