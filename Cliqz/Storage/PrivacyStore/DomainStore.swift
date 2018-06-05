//
//  DomainStore.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RealmSwift

public class Domain: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var state: Int = 0 //0 none, 1 trusted, 2 restricted
    public var trustedTrackers = List<Int>()
    public var restrictedTrackers = List<Int>()
    
    override static public func primaryKey() -> String? {
        return "name"
    }
    
    public var translatedState: DomainState {
        switch state {
        case 0:
            return .empty
        case 1:
            return .trusted
        case 2:
            return .restricted
        default:
            return .empty
        }
    }
}

public enum DomainState {
    case empty
    case trusted
    case restricted
}

public enum ListType {
    case trustedList
    case restrictedList
}

public class DomainStore: NSObject {
    
    public class func get(domain: String) -> Domain? {
        let realm = try! Realm()
        if let domain = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
            return domain
        }
        return nil
    }
    
    public class func create(domain: String) -> Domain {
        let realm = try! Realm()
        let domainObj = Domain()
        domainObj.name = domain
        
        do {
            try realm.write {
                realm.add(domainObj)
            }
        }
        catch let error {
            debugPrint(error)
        }
        
        return domainObj
    }
    
    public class func changeState(domain: Domain, state: DomainState) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                domain.state = intForState(state: state)
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not change state of domain")
        }
    }
    
    public class func add(appId: Int, domain: Domain, list: ListType) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                
                if list == .trustedList {
                    domain.trustedTrackers.append(appId)
                }
                else if list == .restrictedList {
                    domain.restrictedTrackers.append(appId)
                }
                
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not add appId = \(appId) to list = \(list) of domain = \(domain.name)")
        }
    }
    
    public class func remove(appId: Int, domain: Domain, list: ListType) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                
                if list == .trustedList {
                    domain.trustedTrackers.remove(element: appId)
                }
                else if list == .restrictedList {
                    domain.restrictedTrackers.remove(element: appId)
                }
                
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not add appId = \(appId) to list = \(list) of domain = \(domain.name)")
        }
    }
    
    private class func intForState(state: DomainState) -> Int {
        switch state {
        case .empty:
            return 0
        case .trusted:
            return 1
        case .restricted:
            return 2
        }
    }
}

extension List where Element: Comparable {
    func remove(element: Element) {
        let count = self.elements.count
        for i in 0..<count {
            //go backwards
            let index = count - 1 - i
            let item = self[index]
            if item == element {
                self.remove(at: index)
            }
        }
    }
}
