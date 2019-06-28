//
//  ShareExtensionActivities.swift
//  Client
//
//  Created by Mahmoud Adam on 4/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension ShareExtensionHelper {
    
    func getApplicationActivities() -> [UIActivity] {
        #if GHOSTERY
			let applicationActivities = [WiFiProtectionActivity()]
        #else
			let applicationActivities = [UIActivity]()
        #endif
        return applicationActivities
    }
    
    func createStartTabActivityController(_ completionHandler: @escaping (_ completed: Bool, _ activityType: String?) -> Void) -> UIActivityViewController {
        var activityItems = [AnyObject]()
        let shareStartTabtitle = String(format: NSLocalizedString("Hey, I would like to invite you to try the %@ Browser.", tableName: "Cliqz", comment: "Sharing StartTab message"), UserAgentConstants.appName)
        activityItems.append(TitleActivityItemProvider(title: shareStartTabtitle))
        
        if let cliqzdownloadURL = UserAgentConstants.storeURL {
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
    
    func generateFooterText() -> String {
        let shareText = String(format: NSLocalizedString("Shared with %@ Browser for iOS", tableName: "Cliqz", comment: "Shared with [Cliqz Browser | Ghostery Browser] for iOS"), UserAgentConstants.appName)
        var footerText = "\n--\n\(shareText)"
        
        if let url = UserAgentConstants.storeURL {
            let downloadText = String(format: NSLocalizedString("Get it from %@", tableName: "Cliqz", comment: "Get it from the %link%"), url.absoluteString)
            footerText.append("\n\(downloadText)")
        }
        
        return footerText
    }

}
