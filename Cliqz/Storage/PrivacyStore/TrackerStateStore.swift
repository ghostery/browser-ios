//
//  TrackerStateStore.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RealmSwift

public enum TrackerUIState {
    case empty
    case trusted
    case restricted
    case blocked
}

public enum TrackerPageState {
    case trusted
    case restricted
}

public enum TrackerGlobalState {
    case empty
    case blocked
}

public class TrackerState: Object {
    @objc dynamic var appId: Int = -1
    @objc dynamic var state: Int = 0 //0 none, 1 blocked
    @objc dynamic var previousState: Int = 0 //none, 1 blocked
    
    override public static func primaryKey() -> String? {
        return "appId"
    }
    
    public var translatedState: TrackerGlobalState {
        switch state {
        case 0:
            return .empty
        case 1:
            return .blocked
        default:
            return .empty
        }
    }
    
    public var prevTranslatedState: TrackerGlobalState {
        switch previousState {
        case 0:
            return .empty
        case 1:
            return .blocked
        default:
            return .empty
        }
    }
}

public extension Notification.Name {
    public static let BlockedTrackerSetChanged = Notification.Name("BlockedTrackerSetChangedNotification")
}

public class TrackerStateStore: NSObject {
    
    public static let shared = TrackerStateStore()
    
    public var blockedTrackers: Set<Int> = Set() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name.BlockedTrackerSetChanged, object: nil)
        }
    }
    
    public func populateBlockedTrackers() {
        let realm = try! Realm()
        let states = realm.objects(TrackerState.self)
        var set: Set<Int> = Set()
        for state in states {
            if state.translatedState == .blocked {
                set.insert(state.appId)
            }
        }
        //this makes sure the BlockedTrackerSetChanged notification is called only once.
        blockedTrackers = set
    }
    
    public class func createTrackerState(appId: Int) {
        write(appIds: [appId], domain: nil, state: .empty)
    }
    
    public class func change(appIds: [Int], domain: String? = nil, toState: TrackerUIState, completion: (() -> Void)? = nil) {
        write(appIds: appIds, domain: domain, state: toState)
        completion?()
    }
    
    public class func getTrackerState(appId: Int) -> TrackerState? {
        return read(appId: appId)
    }
    
    @discardableResult private class func read(appId: Int) -> TrackerState? {
        let realm = try! Realm()
        if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            return trackerState
        }
        return nil
    }
    
    private class func write(appIds: [Int], domain: String?, state: TrackerUIState) {
        let realm = try! Realm()
        
        guard realm.isInWriteTransaction == false else { return } //avoid exceptions
        
        realm.beginWrite()
        
        if let domain = domain, state == .restricted || state == .trusted {
            //change the domains
            setDomainState(appIds: appIds, domain: domain, state: state, realm: realm)
        }
        else if let domain = domain, state == .blocked || state == .empty {
            //change domains
            setDomainState(appIds: appIds, domain: domain, state: state, realm: realm)
            //change global
            setGlobalState(appIds: appIds, state: state == .blocked ? .blocked : .empty, realm: realm)
        }
        else if state == .blocked || state == .empty {
            //change global
            setGlobalState(appIds: appIds, state: state == .blocked ? .blocked : .empty, realm: realm)
        }
        else {
            fatalError("Unexpected case")
        }
        
        
        do {
            try realm.commitWrite()
            
            if state == .empty {
                TrackerStateStore.shared.blockedTrackers.subtract(appIds)
            }
            else if state == .blocked {
                TrackerStateStore.shared.blockedTrackers.formUnion(appIds)
            }
            
        }
        catch {
            debugPrint("could not change state of trackerState")
            //do I need to cancel the write?
        }
    }
    
    private class func setDomainState(appIds: [Int], domain: String, state: TrackerUIState, realm: Realm) {
        let domainObj: Domain
        
        if let d = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
            domainObj = d
        }
        else {
            domainObj = Domain()
            domainObj.name = domain
            domainObj.state = 0
            realm.add(domainObj)
        }
        
        //moves the current state to the previous state
        for appId in appIds {
            if domainObj.trustedTrackers.contains(appId) {
                if state != .trusted {
                    domainObj.trustedTrackers.remove(element: appId)
                }
                domainObj.previouslyTrustedTrackers.append(appId)
                domainObj.previouslyRestrictedTrackers.remove(element: appId)
            }
            else if domainObj.restrictedTrackers.contains(appId) {
                if state != .restricted {
                    domainObj.restrictedTrackers.remove(element: appId)
                }
                domainObj.previouslyRestrictedTrackers.append(appId)
                domainObj.previouslyTrustedTrackers.remove(element: appId)
            }
            else {
                domainObj.previouslyTrustedTrackers.remove(element: appId)
                domainObj.previouslyRestrictedTrackers.remove(element: appId)
            }
        }
        
        // set the new current state
        if state == .trusted {
            domainObj.trustedTrackers.append(objectsIn: appIds)
        }
        else if state == .restricted {
            domainObj.restrictedTrackers.append(objectsIn: appIds)
        }
        
        realm.add(domainObj, update: true)
    }
    
    private class func setGlobalState(appIds: [Int], state: TrackerGlobalState, realm: Realm) {
        let caseState: TrackerGlobalState = state == .blocked ? .blocked : .empty
        var trackerStatesUpdated: [TrackerState] = []
        var trackerStatesCreated: [TrackerState] = []
        for appId in appIds {
            if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
                trackerState.previousState = trackerState.state
                trackerState.state = intForState(state: caseState)
                trackerStatesUpdated.append(trackerState)
            }
            else {
                let trackerState = TrackerState()
                trackerState.appId = appId
                trackerState.state = intForState(state: caseState)
                trackerState.previousState = intForState(state: .empty)
                trackerStatesCreated.append(trackerState)
            }
        }
        
        realm.add(trackerStatesUpdated, update: true)
        realm.add(trackerStatesCreated, update: true)
    }
    
    private class func intForState(state: TrackerGlobalState) -> Int {
        switch state {
        case .empty:
            return 0
        case .blocked:
            return 1
        }
    }
}
