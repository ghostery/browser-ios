//
//  TabExtension.swift
//  Client
//
//  Created by Tim Palade on 3/27/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import WebKit
import Shared

let urlChangedNotification = Notification.Name(rawValue: "URLChangedNotification")

extension Tab {
    
    func addPrivacy() {
        //Cliqz: Privacy - Add handler for user
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtection")
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtectionPostLoad")
        
        //Cliqz: Privacy - Add user scripts
        //Insert a tab id in the scriptString to identify the tab.
        let preloadSource = try! String(contentsOf: Bundle.main.url(forResource: "preload", withExtension: "js")!).replace("REPLACE_WITH_TAB_ID", replacement: "\(self.tabID)")
        let preloadScript = WKUserScript(source: preloadSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.webView?.configuration.userContentController.addUserScript(preloadScript)
        
        let postloadSource = try! String(contentsOf: Bundle.main.url(forResource: "postload", withExtension: "js")!).replace("REPLACE_WITH_TAB_ID", replacement: "\(self.tabID)")
        let postloadScript = WKUserScript(source: postloadSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webView?.configuration.userContentController.addUserScript(postloadScript)
        
        //Cliqz: Privacy - SetUpBlocking
        if let webView = self.webView {
            self.blockingCoordinator = BlockingCoordinator(webView: webView)
        }
        updateBlocking()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: controlCenterDismissedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: trackersLoadedNotification, object: nil)
    }
    
    @objc func trackersChanged(_ notification: Notification) {
//        if let userInfo = notification.userInfo {
//            if let changes = userInfo["changes"] as? Bool, changes == false {
//                return
//            }
//        }
        updateBlocking()
    }
    
    func didDomainChange() -> Bool {
        if let domain = self.webView?.url?.normalizedHost {
            return domain != lastDomain
        }
        return false
    }
    
    func updateBlocking() {
        blockingCoordinator?.coordinatedUpdate()
    }
    
    func urlChanged() {
        if didDomainChange() {
            updateBlocking()
            if let domain = self.webView?.url?.normalizedHost {
                lastDomain = domain
            }
        }
        self.sendURLChangedNotification()
    }
    
    func sendURLChangedNotification() {
        
        var userInfo: [String: URL] = [:]
        if let url = self.webView?.url {
            userInfo["url"] = url
        }
        
        NotificationCenter.default.post(name: urlChangedNotification, object: self, userInfo: userInfo)
    }
    
}


//this stores information about the current page in a tab
//it is meant to be used with a Tab
class CurrentPageInfo: NSObject {
    
    struct PageTiming {
        let navigationStart: Float
        let loadEventEnd: Float
    }
    
    struct Source {
        let src: String
        let blocked: Bool
        
        func toDict() -> [String: Any] {
            return ["src": self.src, "blocked": self.blocked]
        }
    }
    
    class Info {
        let blocked: Bool
        var sources: [Source] = []
        
        init(blocked: Bool) {
            self.blocked = blocked
        }
        
        func toDict() -> [String: Any] {
            return ["blocked": self.blocked, "sources": self.sources.map{$0.toDict()}]
        }
    }
    
    unowned let tab: Tab
    
    var host: String? = nil
    var startLoadTime: Date? = nil
    var pageTiming: PageTiming? = nil
    //Change the data structures for apps and bugs.
    //Keep a dict where you add the ids as keys and then in sources you add url.
    var appIDs: [Int: Info] = [:]
    var bugIDs: [Int: Info] = [:]
    
    var currentPage: URL? = nil
    
    init(tab: Tab) {
        self.tab = tab
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(trackerDetected), name: detectedTrackerNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //TODO: First find how to colect all data
    //Then figure out the currentPage -> newPage transition
    
    //I need a page complete loading event
    //I need a page changed event
    func pageChanged() {
        //send data: Make sure data is sent once for a page
        //reset
        reset()
    }
    
    private func reset() {
        self.host = nil
        self.startLoadTime = nil
        self.pageTiming = nil
        self.appIDs.removeAll()
        self.bugIDs.removeAll()
    }
    
    //I need to get the host
    //I need to get the start loading time
    //I need the tracker info
    
    
    // I will start with the tracker info.
    @objc func trackerDetected(_ notification: Notification) {
        //filter by tab id.
        //then add the tracker info to the arrays
        
        //TODO: Use the page URL to determine if the page changed.
        //let pageURL = userInfo["url"] as? URL
        
        func addSourceTo(dict: inout [Int: Info], source: Source, id: Int) {
            if let info = dict[id] {
                info.sources.append(source)
            }
            else {
                let info = Info(blocked: true) //blocked is true always for now.
                info.sources = [source]
                dict[id] = info
            }
        }
        
        if let userInfo = notification.userInfo as? [String: Any], let tabIdentifier = userInfo["tabID"] as? Int, tabIdentifier == tab.tabID {
            guard let bug = userInfo["bug"] as? TrackerListBug, let sourceURL = userInfo["sourceURL"] as? URL else {return}
            let source = Source(src: sourceURL.absoluteString, blocked: true) //blocked is true always for now.
            let appID = bug.appId
            
            addSourceTo(dict: &bugIDs, source: source, id: bug.bugId)
            addSourceTo(dict: &appIDs, source: source, id: appID)
        }
    }
    
    func convertAppIds() -> [[String: Any]] {
        let array: [[String: Any]] = []
        
        for (key, value) in appIDs {
            var dict: [String: Any] = [:]
            dict["id"] = key
            dict["blocked"] = value.blocked
            dict["sources"] = value.sources.map{$0.toDict()}
        }
        
        return array
    }
    
    func convertBugIds() -> [String: Any] {
        var dict = [String: Any]()
        
        for (key, value) in bugIDs {
            dict[String(key)] = value.toDict
        }
        
        return dict
    }
}


/**
 * Stats from ghostery when a navigation event happens.
 * @param tabId int
 * @param pageInfo Object: {
 *  timestamp: when page navigation was started
 *  pageTiming: {
 *    timing: {
 *      navigationStart: from performance api
 *      loadEventEnd: from performance api
 *    }
 *  },
 *  host: first party hostname
 * }
 * @param apps Array [{
 *  id: app ID,
 *  blocked: Boolean,
 *  sources: Array [{ src: string url, blocked: boolean }]
 * }, ...]
 * @param bugs Object {
 *  [bug ID]: {
 *    blocked: Boolean,
 *    sources: Array [{ src: string url, blocked: boolean }]
 *  }
 * }
 */












