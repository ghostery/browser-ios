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
        if let realm = try? Realm() {
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
        else {
            //could not init db
            //I need telemetry for this. What do I do in this case?
        }
    }
    
    public class func createTrackerState(appId: Int) {
        write(state: .empty, appIds: [appId], domain: nil)
    }
    
    public class func change(appIds: [Int], domain: String? = nil, toState: TrackerUIState, completion: (() -> Void)? = nil) {
        write(state: toState, appIds: appIds, domain: domain)
        completion?()
    }
    
    public class func undo(appIds: [Int], domain: String? = nil, completion: (() -> Void)? = nil) {
        write(state: nil, appIds: appIds, domain: domain)
        completion?()
    }
    
    public class func getTrackerState(appId: Int) -> TrackerState? {
        return read(appId: appId)
    }
    
    @discardableResult private class func read(appId: Int) -> TrackerState? {
        if let realm = try? Realm() {
            if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
                return trackerState
            }
        }
        return nil
    }
    
    private class func insert(state: TrackerUIState, appId: Int, domainObj: Domain?, trackerState: TrackerState, realm: Realm) {
        switch state {
        case .trusted:
            //set page state to trusted
            setPageState(state: .trusted, appId: appId, domainObj: domainObj, realm: realm)
            //set global state to empty
            setGlobalState(state: .empty, trackerState: trackerState)
        case .restricted:
            //set page state to restricted
            setPageState(state: .restricted, appId: appId, domainObj: domainObj, realm: realm)
            //set global state to empty
            setGlobalState(state: .empty, trackerState: trackerState)
        case .empty:
            //set page state to empty
            setPageState(state: .empty, appId: appId, domainObj: domainObj, realm: realm)
            //set global state to empty
            setGlobalState(state: .empty, trackerState: trackerState)
        case .blocked:
            //set page state to empty
            setPageState(state: .empty, appId: appId, domainObj: domainObj, realm: realm)
            //set global state to blocked
            setGlobalState(state: .blocked, trackerState: trackerState)
        }
    }
    
    class func setPageState(state: TrackerUIState, appId: Int, domainObj: Domain?, realm: Realm) {
        guard let domainObj = domainObj else { return }
        let (_, currListInfo) = currentState(appId: appId, domainObj: domainObj, realm: realm)
        let (_, prevListInfo) = previousState(appId: appId, domainObj: domainObj, realm: realm)
        
        //clean previous state
        if let (prevList, prevIndex) = prevListInfo {
            if prevList == .prevRestrictedList {
                domainObj.previouslyRestrictedTrackers.remove(at: prevIndex)
            }
            else if prevList == .prevTrustedList {
                domainObj.previouslyTrustedTrackers.remove(at: prevIndex)
            }
        }
        
        //move current state to previous
        if let (list, index) = currListInfo {
            if list == .trustedList, !domainObj.previouslyTrustedTrackers.contains(appId) {
                domainObj.previouslyTrustedTrackers.append(appId)
                domainObj.trustedTrackers.remove(at: index)
            }
            else if list == .restrictedList, !domainObj.previouslyRestrictedTrackers.contains(appId) {
                domainObj.previouslyRestrictedTrackers.append(appId)
                domainObj.restrictedTrackers.remove(at: index)
            }
        }
        
        //set current state
        if state == .trusted {
            if !domainObj.trustedTrackers.contains(appId) {
                domainObj.trustedTrackers.append(appId)
            }
        }
        else if state == .restricted {
            if !domainObj.restrictedTrackers.contains(appId) {
                domainObj.restrictedTrackers.append(appId)
            }
        }
    }
    
    class func setGlobalState(state: TrackerGlobalState, trackerState: TrackerState) {
        trackerState.previousState = trackerState.state
        trackerState.state = intForState(state: state)
    }
    
    private class func write(state: TrackerUIState?, appIds: [Int], domain: String?) {
        autoreleasepool {
            if let realm = try? Realm() {
                guard realm.isInWriteTransaction == false else { return } //avoid exceptions
                
                realm.beginWrite()
                
                var domainObj: Domain? = nil
                
                if let domain = domain {
                    
                    if let d = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
                        domainObj = d
                    }
                    else {
                        domainObj = Domain()
                        domainObj!.name = domain
                        realm.add(domainObj!)
                    }
                }
                
                var trackerStatesToUpdate: [TrackerState] = []
                var trackerStatesToAdd: [TrackerState] = []
                
                for appId in appIds {
                    
                    let toState: TrackerUIState
                    
                    if let s = state {
                        toState = s
                    }
                    else {
                        let (prevState, _) = previousState(appId: appId, domainObj: domainObj, realm: realm)
                        toState = prevState
                    }
                    
                    let trackerState: TrackerState
                    
                    if let ts = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
                        trackerState = ts
                        trackerStatesToUpdate.append(ts)
                    }
                    else {
                        trackerState = TrackerState()
                        trackerState.appId = appId
                        trackerState.state = intForState(state: .empty)
                        trackerState.previousState = intForState(state: .empty)
                        trackerStatesToAdd.append(trackerState)
                    }
                    
                    insert(state: toState, appId: appId, domainObj: domainObj, trackerState: trackerState, realm: realm)
                    
                    if toState == .empty {
                        TrackerStateStore.shared.blockedTrackers.remove(appId)
                    }
                    else if toState == .blocked {
                        TrackerStateStore.shared.blockedTrackers.insert(appId)
                    }
                }
                
                realm.add(trackerStatesToUpdate, update: true)
                realm.add(trackerStatesToAdd)
                
                if let d = domainObj {
                    realm.add(d, update: true)
                }
                
                do {
                    try realm.commitWrite()
                }
                catch {
                    debugPrint("could not change state of trackerState")
                    //do I need to cancel the write?
                }
            }
        }
    }
    
    //returns the state and a list with an index if the element is found there
    private class func currentState(appId: Int, domainObj: Domain?, realm: Realm) -> (TrackerUIState, (ListType, Int)?) {
        if let index = domainObj?.restrictedTrackers.index(of: appId) {
            return (.restricted, (.restrictedList, index))
        }
        else if let index = domainObj?.trustedTrackers.index(of: appId) {
            return (.trusted, (.trustedList, index))
        }
        
        if let globalState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            return (globalState.translatedState == .blocked ? .blocked : .empty, nil)
        }
        
        return (.empty, nil)
    }
    
    //returns the state and a list with an index if the element is found there
    private class func previousState(appId: Int, domainObj: Domain?, realm: Realm) -> (TrackerUIState, (ListType, Int)?) {
        if let index = domainObj?.previouslyRestrictedTrackers.index(of: appId) {
            return (.restricted, (.prevRestrictedList, index))
        }
        else if let index = domainObj?.previouslyTrustedTrackers.index(of: appId) {
            return (.trusted, (.prevTrustedList, index))
        }
        
        if let globalState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            return (globalState.prevTranslatedState == .blocked ? .blocked : .empty, nil)
        }
        
        return (.empty, nil)
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
