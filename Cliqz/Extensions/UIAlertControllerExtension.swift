//
//  UIAlertControllerExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 7/6/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func getRestoreTabsAlert() -> UIAlertController {
        return UIAlertController(
            title: NSLocalizedString("Well, this is embarrassing.", tableName: "Cliqz", comment: "Restore Tabs Prompt Title"),
            message: NSLocalizedString("Looks like Ghostery crashed previously. Would you like to restore your tabs?", tableName: "Cliqz", comment: "Restore Tabs Prompt Description"),
            preferredStyle: .alert
        )
    }
}
