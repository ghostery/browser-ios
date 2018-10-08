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
open class BrowserActions: RCTEventEmitter {

    @objc(openLink:)
    func openLink(url: NSString) {
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
        getHistory(query: query as String) { results in
            callback([results])
        }
    }
    
    // `weak` usage here allows deferred queue to be the owner. The deferred is always filled and this set to nil,
    // this is defensive against any changes to queue (or cancellation) behaviour in future.
    private weak var currentDbQuery: Cancellable?

    func getHistory(query: String, callback: @escaping ([[String: String]]) -> Void) {
        
        DispatchQueue.main.async {
            guard let profile = (UIApplication.shared.delegate as? AppDelegate)?.profile as? BrowserProfile else {
                assertionFailure("nil profile")
                callback([])
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if query.isEmpty {
                    //load(Cursor(status: .success, msg: "Empty query"))
                    callback([])
                    return
                }
                
                if let currentDbQuery = self?.currentDbQuery {
                    profile.db.cancel(databaseOperation: WeakRef(currentDbQuery))
                }
                
                let frecentHistory = profile.history.getFrecentHistory()
                let deferred = frecentHistory.getSites(whereURLContains: query, historyLimit: 100, bookmarksLimit: 5)
                self?.currentDbQuery = deferred as? Cancellable
                
                deferred.uponQueue(.main) { result in
                    defer {
                        self?.currentDbQuery = nil
                    }
                    
                    guard let deferred = deferred as? Cancellable, !deferred.cancelled else {
                        callback([])
                        return
                    }
                    
                    // Failed cursors are excluded in .get().
                    if let cursor = result.successValue {
                        
                        var results: [[String: String]] = []
                        
                        for site in cursor {
                            if let site = site {
                                let d = ["url": site.url, "title": site.title]
                                results.append(d)
                            }
                        }
                        
                        callback(results)
                    }
                    else {
                        callback([])
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
