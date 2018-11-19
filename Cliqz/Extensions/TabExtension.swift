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

class PageTimingInterceptor: NSObject {
    static let shared = PageTimingInterceptor()
}

let pageTimingNotification = Notification.Name(rawValue: "pageTimingNotification")

extension PageTimingInterceptor: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dict = message.body as? [String: Any] {
            NotificationCenter.default.post(name: pageTimingNotification, object: self, userInfo: dict)
        }
    }
}

extension Tab {
    
    func addPrivacy() {
        //Cliqz: Privacy - Add handler for user
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtection")
        self.webView?.configuration.userContentController.add(URLInterceptor.shared, name: "cliqzTrackingProtectionPostLoad")
        
        //Cliqz: Privacy - Add user scripts
        let preloadSource = try! String(contentsOf: Bundle.main.url(forResource: "preload", withExtension: "js")!).replace("REPLACE_WITH_TAB_ID", replacement: "\(self.tabID)")
        let preloadScript = WKUserScript(source: preloadSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.webView?.configuration.userContentController.addUserScript(preloadScript)
        
        let postloadSource = try! String(contentsOf: Bundle.main.url(forResource: "postload", withExtension: "js")!).replace("REPLACE_WITH_TAB_ID", replacement: "\(self.tabID)")
        let postloadScript = WKUserScript(source: postloadSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        self.webView?.configuration.userContentController.addUserScript(postloadScript)
        //pageTiming
        
        #if PAID
        self.webView?.configuration.userContentController.add(PageTimingInterceptor.shared, name: "pageTiming")
        let timingSource = try! String(contentsOf: Bundle.main.url(forResource: "timing", withExtension: "js")!).replace("REPLACE_WITH_TAB_ID", replacement: "\(self.tabID)")
        let timingScript = WKUserScript(source: timingSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.webView?.configuration.userContentController.addUserScript(timingScript)
        #endif
        
        //Cliqz: Privacy - SetUpBlocking
        if let webView = self.webView {
            self.blockingCoordinator = BlockingCoordinator(webView: webView)
        }
        updateBlocking()
        #if PAID
        NotificationCenter.default.addObserver(self, selector: #selector(privacyChanged), name: Notification.Name.privacyStatusChanged, object: nil)
        #else
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: controlCenterDismissedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackersChanged), name: trackersLoadedNotification, object: nil)
        #endif
    }
    
    func updateBlocking() {
        blockingCoordinator?.coordinatedUpdate()
    }
    
    #if PAID
    @objc func privacyChanged(_ notification: Notification) {
        updateBlocking()
    }
    #else
    @objc func trackersChanged(_ notification: Notification) {
//        if let userInfo = notification.userInfo {
//            if let changes = userInfo["changes"] as? Bool, changes == false {
//                return
//            }
//        }
        updateBlocking()
    }
    #endif
    
    func didDomainChange() -> Bool {
        if let domain = self.webView?.url?.normalizedHost {
            return domain != lastDomain
        }
        return false
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
        let navigationStart: Int
        let loadEventEnd: Int
        
        func toDict() -> [String: Any] {
            return ["navigationStart": self.navigationStart, "loadEventEnd": self.loadEventEnd]
        }
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
    var dataSentForCurrentPage = false
    
    init(tab: Tab) {
        self.tab = tab
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterceptedURL), name: detectedTrackerNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterceptedURL), name: newInterceptedURLNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pageTimingReceived), name: pageTimingNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
     * async pushGhosteryPageStats(tabId, pageInfo, apps, bugs)
     */
    
    func sendData() {

        guard dataSentForCurrentPage == false else {return}
        dataSentForCurrentPage = true
        
        //Should I push if there were no trackers detected?
        //Answer is no.
        guard bugIDs.count > 0 else { /*print("Will send -- No trackers for \(String(describing: currentPage))"); */ return}
        
        let tabID = self.tab.tabID
        let apps = convertAppIds()
        let bugs = convertBugIds()
        
        let timeStamp = Int((self.startLoadTime?.timeIntervalSince1970 ?? 0.0) * 1000.0)
        let pageInfo: [String: Any]
        
        if let pt = self.pageTiming {
            let pageTime: [String: Any] = ["timing": pt.toDict()]
            pageInfo = ["timestamp": timeStamp, "pageTiming": pageTime, "host": self.host ?? ""]
        }
        else {
            pageInfo = ["timestamp": timeStamp, "host": self.host ?? ""]
        }
        
        //send stuff here
        
        //let currentP = self.currentPage
        DispatchQueue.global(qos: .utility).async {
            //print("Will send data for tab = \(tabID) and page = \(String(describing: currentP))")
            Engine.sharedInstance.getBridge().callAction("insights:pushGhosteryPageStats", args: [tabID, pageInfo, apps, bugs])
        }
        
    }
    
    func pageChanged() {
        //send data: Make sure data is sent once for a page - Done using a flag (dataSentForCurrentPage)
        sendData()
        //reset
        reset()
    }
    
    private func reset() {
        self.host = nil
        self.startLoadTime = nil
        self.pageTiming = nil
        self.appIDs.removeAll()
        self.bugIDs.removeAll()
        self.dataSentForCurrentPage = false
    }
    
    //Page loaded event
    //Careful: This event can come after the page was changed. Check the currentURL.
    @objc func pageTimingReceived(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any],
            let tabIdentifier = userInfo["tabIdentifier"] as? Int,
            let pageURL = userInfo["pageURL"] as? String,
            tabIdentifier == tab.tabID,
            currentPage?.absoluteString == pageURL {
            
            guard let navStart = userInfo["navigationStart"] as? Int, let loadEnd = userInfo["loadEventEnd"] as? Int, loadEnd > 0 else {return}
            print("userInfo = \(userInfo)")
            self.pageTiming = PageTiming(navigationStart: navStart, loadEventEnd: loadEnd)
            self.sendData()
        }
    }
    
    //Page changed event
    @objc func handleInterceptedURL(_ notification: Notification) {
        //filter by tab id.
        //then add the tracker info to the arrays
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
            
            //Use the page URL to determine if the page changed.
            guard let pageURL = userInfo["url"] as? URL, let domainURL = userInfo["domainURL"] as? URL else {return}
            if (currentPage == nil) {
                currentPage = pageURL
                self.host = domainURL.absoluteString
                self.startLoadTime = Date()
            }
            else if (pageURL.absoluteString != currentPage?.absoluteString) {
                //pageChanged
                pageChanged()
                currentPage = pageURL
                self.host = domainURL.absoluteString
                self.startLoadTime = Date()
            }
            
            guard let bug = userInfo["bug"] as? TrackerListBug, let sourceURL = userInfo["sourceURL"] as? URL else {return}
            let source = Source(src: sourceURL.absoluteString, blocked: true) //blocked is true always for now.
            let appID = bug.appId
            
            addSourceTo(dict: &bugIDs, source: source, id: bug.bugId)
            addSourceTo(dict: &appIDs, source: source, id: appID)
        }
    }
    
    func convertAppIds() -> [[String: Any]] {
        var array: [[String: Any]] = []
        
        for (key, value) in appIDs {
            var dict: [String: Any] = [:]
            dict["id"] = key
            dict["blocked"] = value.blocked
            dict["sources"] = value.sources.map{$0.toDict()}
            array.append(dict)
        }
        
        return array
    }
    
    func convertBugIds() -> [String: Any] {
        var dict = [String: Any]()
        
        for (key, value) in bugIDs {
            dict[String(key)] = value.toDict()
        }
        
        return dict
    }
}
