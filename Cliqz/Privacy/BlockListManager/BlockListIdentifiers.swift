//
//  BlockListIdentifiers.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

final class BlockListIdentifiers {
    
    class func antitrackingBlockSelectedIdentifiers() -> [String] {
        let appIds = TrackerStore.shared.all()
        
        func getBugIds(appIds: [Int]) -> [Int] {
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
        let exceptions = ["adblocker_exceptions"] //exceptions go at the end.
        return adBlockerChunks() + exceptions
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
}

