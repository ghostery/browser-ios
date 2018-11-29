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
    
    class func alertWithCancelAndAction(text: String, actionButtonTitle: String, actionCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: text,
            preferredStyle: .alert
        )
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel button title in the urlbar"), style: .destructive, handler: nil)
        
        let action = UIAlertAction(
            title: actionButtonTitle,
            style: .default,
            handler: actionCallback
        )
        
        alert.addAction(cancel)
        alert.addAction(action)
        return alert
    }
    
    class func alertWithOkay(text: String) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: text,
            preferredStyle: .alert
        )
        
        let okay = UIAlertAction(title: NSLocalizedString("Okay", tableName: "Cliqz", comment: "Okay button for alerts"), style: .destructive, handler: nil)
        
        alert.addAction(okay)
        return alert
    }
}
