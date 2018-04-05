//
//  BrowserConnectExtention.swift
//  Client
//
//  Created by Mahmoud Adam on 4/6/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension BrowserViewController {
    
    func openTabViaConnect(notification: NSNotification) {
        guard let data = notification.object as? [String: AnyObject],
            let urlString = data["url"] as? String,
            let isPrivate = data["isPrivate"] as? Bool else {
            return
        }
        if let url = URL(string: urlString)  {
            self.openURLInNewTab(url, isPrivate: isPrivate, isPrivileged: false)
        }
    }
    
    func downloadVideoViaConnect(notification: NSNotification) {
        guard let data = notification.object as? [String: String], let urlString = data["url"] else {
            return
        }
        self.doDownloadVideo(urlString)
    }
}
