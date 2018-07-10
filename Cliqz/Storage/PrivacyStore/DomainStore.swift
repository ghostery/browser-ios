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
    public var previouslyTrustedTrackers = List<Int>()
    public var previouslyRestrictedTrackers = List<Int>()
    
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
    case prevTrustedList
    case prevRestrictedList
}

public class DomainStore: NSObject {
    
    public class func get(domain: String) -> Domain? {
        let realm = try! Realm()
        if let domain = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
            return domain
        }
        return nil
    }
    
    public class func getOrCreateDomain(domain: String) -> Domain {
        //if we have done anything with this domain before we will have something in the DB
        //otherwise we need to create it
        if let domainO = DomainStore.get(domain: domain) {
            return domainO
        } else {
            return DomainStore.create(domain: domain)
        }
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
    
    public class func changeState(domain: String, state: DomainState) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                let domain = getOrCreateDomain(domain: domain)
                domain.state = intForState(state: state)
                realm.add(domain)
            }
        }
        catch {
            debugPrint("could not change state of domain")
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
