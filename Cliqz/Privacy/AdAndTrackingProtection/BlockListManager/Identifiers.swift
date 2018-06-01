//
//  BlockListIdentifiers.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Storage

final class BlockListIdentifiers {
    
    class func antitrackingIdentifiers() -> [BlockListIdentifier] {
        return Array(CategoriesHelper.categories)
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
        
        
        //remove extension and sort
        return paths.map({ (p) -> String in
            return adblockerFilename(path: p)
        }).sorted(by: { (p1, p2) -> Bool in
            return adblockerFileNumber(path: p1) < adblockerFileNumber(path: p2)
        })
    }
}

class AntitrackingJSONIdentifiers {
    
    class func jsonIdentifiers(forBlockListId: BlockListIdentifier, domain: String?) -> Set<JSONIdentifier> {
        return Set(antitrackingBlockSelectedIdentifiers(forBlockListId: forBlockListId, domain: domain))
    }
    
    class func antitrackingBlockAllIdentifiers() -> [JSONIdentifier] {
        return ["ghostery_content_blocker"]
    }
    
    class private func antitrackingBlockSelectedIdentifiers(forBlockListId: BlockListIdentifier, domain: String? = nil) -> [JSONIdentifier] {
        
        func getBugIds(appIds: Set<Int>) -> [Int] {
            return appIds.flatMap { (appId) -> [Int] in
                return TrackerList.instance.app2bug[appId] ?? []
            }
        }
        
        let appIds = getAppIds(forBlockListId: forBlockListId, domain: domain)
        let bugIds = getBugIds(appIds: appIds).map { i in String(i) }
        
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
        for app in TrackerList.instance.globalTrackerList() {
            if app.state(domain: domain) == .blocked && app.category == forBlockListId {
                global.insert(app.appId)
            }
        }
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            specific2domainTrusted = Set(domainObj.trustedTrackers.filter(filter))
            specific2domainRestricted = Set(domainObj.restrictedTrackers.filter(filter))
        }
        
        global.formUnion(specific2domainRestricted)
        global.subtract(specific2domainTrusted)
        
        return global
    }
}

