//
//  BlockListIdentifiers.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Storage

final class BlockListIdentifiers {
    
    class func antitrackingBlockSelectedIdentifiers(domain: String?) -> [String] {
        
        let appIds = getAppIds(domain: domain)
        
        func getBugIds(appIds: Set<Int>) -> [Int] {
            return appIds.flatMap { (appId) -> [Int] in
                return TrackerList.instance.app2bug[appId] ?? []
            }
        }
        
        let bugIds = getBugIds(appIds: appIds).map { i in String(i) }
        
        return bugIds
    }
    
    class func antitrackingBlockAllIdentifiers() -> [String] {
        return ["ghostery_content_blocker"]
    }
    
    class func adblockingIdentifiers() -> [String] {
        // exceptions are now part of the chunks
        return adBlockerChunks()
    }
    
    class private func adBlockerChunks() -> [String] {
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
    
    class private func getAppIds(domain: String?) -> Set<Int> {
        
        //load global trackers
        //load trackers specific to this page
        var specific2domainRestricted: Set<Int> = Set()
        var specific2domainTrusted: Set<Int> = Set()
        
        //TODO: Solve this bottle neck
        var global: Set<Int> = Set(TrackerList.instance.globalTrackerList().filter({ (app) -> Bool in
            return app.state.translatedState == .blocked
        }).map { (app) -> Int in
            return app.appId
        })
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            specific2domainTrusted = Set(domainObj.trustedTrackers)
            specific2domainRestricted = Set(domainObj.restrictedTrackers)
        }
        
        global.formUnion(specific2domainRestricted)
        global.subtract(specific2domainTrusted)
        
        return global
    }
}

