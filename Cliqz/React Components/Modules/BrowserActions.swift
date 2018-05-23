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

    @objc(searchHistory:callback:)
    func searchHistory(query: NSString, callback: RCTResponseSenderBlock) {
        debugPrint("searchHistory")
        callback(getHistory())
    }

    func getHistory() -> [[String: String]] {
        var results: [[String: String]] = []
        if let r = HistoryListener.shared.historyResults {
            for site in r {
                let d = ["url": site!.url, "title": site!.title]
                results.append(d)
            }
        }
        return results
    }

}
