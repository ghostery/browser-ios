//
//  ShareExtensionActivities.swift
//  Client
//
//  Created by Mahmoud Adam on 4/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension ShareExtensionHelper {
    static let cliqzdownloadURL = URL(string:"https://cliqz.com/download")
    
    func getApplicationActivities() -> [UIActivity] {
        let applicationActivities = [WiFiProtectionActivity()]
        return applicationActivities
    }
    
    func createCliqzTabActivityController(_ completionHandler: @escaping (_ completed: Bool, _ activityType: String?) -> Void) -> UIActivityViewController {
        var activityItems = [AnyObject]()
        let title = NSLocalizedString("Hey, I would like to invite you to try the Cliqz Browser.", tableName: "Cliqz", comment: "Sharing FreshTab message")
        activityItems.append(TitleActivityItemProvider(title: title))
        
        if let cliqzdownloadURL = ShareExtensionHelper.cliqzdownloadURL {
            activityItems.append(cliqzdownloadURL as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: getApplicationActivities())
        
        // Hide 'Add to Reading List' which currently uses Safari.
        // We would also hide View Later, if possible, but the exclusion list doesn't currently support
        // third-party activity types (rdar://19430419).
        activityViewController.excludedActivityTypes = [
            UIActivityType.addToReadingList,
        ]
        
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if !completed {
                completionHandler(completed, activityType.map { $0.rawValue })
                return
            }
            // Bug 1392418 - When copying a url using the share extension there are 2 urls in the pasteboard.
            // This is a iOS 11.0 bug. Fixed in 11.2
            if UIPasteboard.general.hasURLs, let url = UIPasteboard.general.urls?.first {
                UIPasteboard.general.urls = [url]
            }
            
            completionHandler(completed, activityType.map { $0.rawValue })
        }
        return activityViewController
    }

}
