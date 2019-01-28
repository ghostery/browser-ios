//
//  BlockListIdentifiers.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit
import Storage

class ChangeCoordinator {
    static let shared = ChangeCoordinator()
    
    var last_global: PersistentSet<Int> = PersistentSet(id: "ChangeCoordinatorLastGlobal")
    var webViewHashes: Set<Int> = Set()
    
    class func generateGlobal(domain: String?) -> Set<Int> {
        
        var specific2domainRestricted: Set<Int> = Set()
        var specific2domainTrusted: Set<Int> = Set()
        
        var global: Set<Int> = TrackerStateStore.shared.blockedTrackers
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            specific2domainTrusted = Set(domainObj.trustedTrackers)
            specific2domainRestricted = Set(domainObj.restrictedTrackers)
        }
        
        global.formUnion(specific2domainRestricted)
        global.subtract(specific2domainTrusted)
        
        return global
    }
    
    func identifiersWithChanges(domain: String?) -> Set<BlockListIdentifier> {
        let global = ChangeCoordinator.generateGlobal(domain: domain)
        let appIdsChanged = last_global.symmetricDifference(global)
        last_global.replaceWith(set: global)
        var categories: Set<BlockListIdentifier> = Set()
        for appId in appIdsChanged {
            if let app = TrackerList.instance.apps[appId] {
                categories.insert(app.category)
            }
        }
        return categories
    }
    
    private func doYouRecognizeWebView(webView: WKWebView?) -> Bool {
        if let webView = webView {
            let result = webViewHashes.contains(webView.hash)
            webViewHashes.insert(webView.hash)
            return result
        }
        return false
    }
    
    func areBlocklistsLoadedFor(webView: WKWebView?) -> Bool {
        //TODO: I need a better way to decide whether blocklists are loaded
        //This works for now since I only remove blocklists at the end of a load, just before I load the new ones.
        return doYouRecognizeWebView(webView: webView)
    }
        
}

final class BlockListIdentifiers {
    
    class func antitrackingIdentifiers(domain: String?, webView: WKWebView?) -> ([BlockListIdentifier], [String: Bool]?) {
        #if PAID
        return ([], nil)
        #else
        if ChangeCoordinator.shared.areBlocklistsLoadedFor(webView: webView) {
            return (Array.init(ChangeCoordinator.shared.identifiersWithChanges(domain: domain)), ["hitCache": false])
        }
        else {
            return (Array.init(CategoriesHelper.categories), ["hitCache": true])
        }
        #endif
    }
    
    class func adblockingIdentifiers() -> [BlockListIdentifier] {
        // exceptions are now part of the chunks
        return adBlockerChunks()
    }
    
    class private func adBlockerChunks() -> [BlockListIdentifier] {
        guard var paths = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath + "/AdBlocker/Chunks/") else { return [] }
        
        func adblockerFileNumber(path: String) -> Int {
            guard let filename = path.components(separatedBy: ".").first else { fatalError("adblocker paths have invalid format") }
            let fileComp = filename.components(separatedBy: "_")
            guard fileComp.count == 2 else { fatalError("adblocker paths have invalid format") }
            return Int(fileComp[1])!
        }
        
        func adblockerFilename(path:String) -> String {
            guard let filename = path.components(separatedBy: ".").first else { fatalError("adblocker paths have invalid format") }
            return filename
        }
        
        
        //remove extension (and sort)
        return paths.map({ (p) -> String in
            return adblockerFilename(path: p)
        })//.sorted(by: { (p1, p2) -> Bool in
        //    return adblockerFileNumber(path: p1) < adblockerFileNumber(path: p2)
        //})
    }
}

class AntitrackingJSONIdentifiers {
    
    class func jsonIdentifiers(forBlockListId: BlockListIdentifier, domain: String?) -> Set<JSONIdentifier> {
        return antitrackingBlockSelectedIdentifiers(forBlockListId: forBlockListId, domain: domain)
    }
    
    class func antitrackingBlockAllIdentifiers() -> [JSONIdentifier] {
		// TODO: The second identifier will be ignored according to current implementation, so 3rd party cookies blocking rule is added to the full content blocker for now.
        return ["ghostery_content_blocker", "3rd_party_cookies_blocker"]
    }
    
    class private func antitrackingBlockSelectedIdentifiers(forBlockListId: BlockListIdentifier, domain: String? = nil) -> Set<JSONIdentifier> {
        
        func getBugIds(appIds: Set<Int>) -> [Int] {
            return appIds.flatMap { (appId) -> [Int] in
                return TrackerList.instance.app2bug[appId] ?? []
            }
        }
                //get appIds is the bottle neck
        let appIds = getAppIds(forBlockListId: forBlockListId, domain: domain)
        
        var bugIds: Set<JSONIdentifier> = Set()
        getBugIds(appIds: appIds).forEach({ (appId) in
            bugIds.insert(String(appId))
        })
        
        return bugIds
    }
    
    class private func getAppIds(forBlockListId: BlockListIdentifier, domain: String?) -> Set<Int> {
        
        //forBlockListId == app.category
        
        //filter out appIds that do not belong to this category
        func filter(appId: Int) -> Bool {
            if let app = TrackerList.instance.apps[appId] {
                return app.category == forBlockListId
            }
            return false
        }
        //load global trackers
        //load trackers specific to this page
        var specific2domainRestricted: Set<Int> = Set()
        var specific2domainTrusted: Set<Int> = Set()
        
        var global: Set<Int> = Set()
        for appId in TrackerStateStore.shared.blockedTrackers {
            //app.state(domain: domain) == .blocked can take time if the domain or the tracker state are not in the DB already
            //to avoid this bottleneck the tracker states are created in the ApplyDefaultsOperation.
            if filter(appId: appId) {
                global.insert(appId)
            }
        }
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            for appId in domainObj.trustedTrackers {
                if filter(appId: appId) {
                    specific2domainTrusted.insert(appId)
                }
            }
            
            for appId in domainObj.restrictedTrackers {
                if filter(appId: appId) {
                    specific2domainRestricted.insert(appId)
                }
            }
        }
        
        
        global.formUnion(specific2domainRestricted)
        global.subtract(specific2domainTrusted)

        return global
    }
}

