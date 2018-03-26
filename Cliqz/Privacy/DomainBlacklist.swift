//
//  DomainBlacklist.swift
//  BrowserCore
//
//  Created by Tim Palade on 2/23/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import Foundation
import RealmSwift

class BlacklistEntry: Object {
    @objc dynamic var timestamp = Date()
    @objc dynamic var domain = ""
    @objc dynamic var antitrackingOn = false
    @objc dynamic var adblockingOn = false
    
    override static func primaryKey() -> String? {
        return "domain"
    }
}

class DomainBlacklist {
    
    private enum Key {
        case antitracking
        case adblocking
    }
    
    class func shouldAntitrackingBeEnabled(on domain: String?) -> Bool {
        let realm = try! Realm()
        if let entry = realm.object(ofType: BlacklistEntry.self, forPrimaryKey: domain) {
            return entry.antitrackingOn
        }
        
        return true
    }
    
    class func shouldAdBlockingBeEnabled(on domain: String?) -> Bool {
        let realm = try! Realm()
        if let entry = realm.object(ofType: BlacklistEntry.self, forPrimaryKey: domain) {
            return entry.adblockingOn
        }
        
        return true
    }
    
    class func setAntitracking(on: Bool, domain: String?) {
        change(domain: domain, key: .antitracking, turnOn: on)
    }
    
    class func setAdblocking(on: Bool, domain: String?) {
        change(domain: domain, key: .adblocking, turnOn: on)
    }
    
    private class func change(domain: String?, key: Key, turnOn: Bool) {
        
        guard let domain = domain else {
            debugPrint("domain is nil")
            return
        }
        
        let realm = try! Realm()
        let entry: BlacklistEntry
        var update = false
        if let e = realm.object(ofType: BlacklistEntry.self, forPrimaryKey: domain) {
            entry = e
            update = true
        }
        else {
            entry = createBlacklistEntry(domain: domain)
        }
        if key == .antitracking {
            entry.antitrackingOn = turnOn
        }
        else if key == .adblocking {
            entry.adblockingOn = turnOn
        }
        
        try! realm.write {
            realm.add(entry, update: update)
        }
    }
    
    private class func createBlacklistEntry(domain: String) -> BlacklistEntry {
        let entry = BlacklistEntry()
        return entry
    }
}
