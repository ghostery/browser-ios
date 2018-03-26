//
//  TabExtension.swift
//  Client
//
//  Created by Tim Palade on 3/27/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import WebKit

extension Tab {
    
    func addPrivacy() {
        //Cliqz: Privacy - Add handler for user
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtection")
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtectionPostLoad")
        
        //Cliqz: Privacy - Add user scripts
        let preloadSource = try! String(contentsOf: Bundle.main.url(forResource: "preload", withExtension: "js")!)
        let preloadScript = WKUserScript(source: preloadSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.webView?.configuration.userContentController.addUserScript(preloadScript)
        
        let postloadSource = try! String(contentsOf: Bundle.main.url(forResource: "postload", withExtension: "js")!)
        let postloadScript = WKUserScript(source: postloadSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webView?.configuration.userContentController.addUserScript(postloadScript)
        
        //Cliqz: Privacy - SetUpBlocking
        setupBlocking()
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: trackerViewDismissedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: trackersLoadedNotification, object: nil)
    }
    
    func setupBlocking() {
        
        if UserPreferences.instance.blockingMode == .all {
            BlockListManager.shared.getBlockLists(forIdentifiers: BlockListIdentifiers.antitrackingIdentifiers, callback: { (lists) in
                DispatchQueue.main.async {
                    if let webView = self.webView {
                        //Remember to add the adblocking rules if you remove all blocklists
                        webView.configuration.userContentController.removeAllContentRuleLists()
                        lists.forEach(webView.configuration.userContentController.add)
                        debugPrint("WebView added blocklists")
                        webView.reload()
                    }
                }
            })
        } else if UserPreferences.instance.blockingMode == .selected {
            let appIds = TrackerStore.shared.all()
            BlockListManager.shared.getBlockLists(appIds: appIds, callback: { (lists) in
                DispatchQueue.main.async {
                    if let webView = self.webView {
                        //Remember to add the adblocking rules if you remove all blocklists
                        webView.configuration.userContentController.removeAllContentRuleLists()
                        lists.forEach(webView.configuration.userContentController.add)
                        debugPrint("WebView added blocklists")
                        self.reload()
                    }
                }
            })
        }
        else if UserPreferences.instance.blockingMode == .none {
            DispatchQueue.main.async {
                //Remember to add the adblocking rules if you remove all blocklists
                if let webView = self.webView {
                    webView.configuration.userContentController.removeAllContentRuleLists()
                    debugPrint("WebView removed blocklists")
                }
            }
        }
    }
    
    @objc func trackersChanged(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let changes = userInfo["changes"] as? Bool, changes == false {
                return
            }
        }
        setupBlocking()
    }
    
}
