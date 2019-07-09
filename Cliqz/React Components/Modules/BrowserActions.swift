//
//  BrowserActions.swift
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import React
import Shared
import Storage

@objc(BrowserActions)
class BrowserActions: RCTEventEmitter {
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(openLink:query:isSearchEngine:)
    public func openLink(url: NSString, query: NSString, isSearchEngine: Bool) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: OpenUrlSearchNotification, object: url, userInfo: nil)
        }
    }

    @objc(copyValue:)
    func copyValue(result: NSString) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CopyValueSearchNotification, object: result, userInfo: nil)
        }
    }

    @objc(callNumber:)
    func callNumber(number: NSString) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: CallSearchNotification, object: number, userInfo: nil)
        }
    }

    @objc(openMap:)
    func openMap(url: NSString) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: MapSearchNotification, object: url, userInfo: nil)
        }
    }
    
    @objc(hideKeyboard)
    func hideKeyboard() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: HideKeyboardSearchNotification, object: nil, userInfo: nil)
        }
    }

    @objc(searchHistory:callback:)
    func searchHistory(query: NSString, callback: @escaping RCTResponseSenderBlock) {
        debugPrint("searchHistory")

        DispatchQueue.main.async {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                if let profile = appDel.profile {
                    var results: [[String: String]] = []
                    let frecentHistory = profile.history.getFrecentHistory()
                    frecentHistory.getSites(whereURLContains: query as String, historyLimit: 100, bookmarksLimit: 5)
                    >>== { (sites: Cursor) in
                        for site in sites {
                            if let siteUrl = site?.url, let url = URL(string: siteUrl), !self.isDuckduckGoRedirectURL(url) {
                                let d = ["url": site!.url, "title": site!.title]
                                results.append(d)
                            }
                        }
                        callback([results])
                    }
                }
            }
        }
    }
    
    private func isDuckduckGoRedirectURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString
        if "duckduckgo.com" == url.host,
            urlString.contains("kh="),
            urlString.contains("uddg=") {
            return true
        }
        
        return false
    }
}
