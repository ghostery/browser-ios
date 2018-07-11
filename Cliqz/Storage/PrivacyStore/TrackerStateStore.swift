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
        write(appIds: [appId], domain: nil, state: .empty)
    }
    
    public class func change(appIds: [Int], domain: String? = nil, toState: TrackerUIState, completion: (() -> Void)? = nil) {
        write(appIds: appIds, domain: domain, state: toState)
        completion?()
    }
    
    public class func undo(appIds: [Int], domain: String? = nil, completion: (() -> Void)? = nil) {
        writePrevious(appIds: appIds, domain: domain)
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
    
    private class func write(appIds: [Int], domain: String?, state: TrackerUIState) {
        if let realm = try? Realm() {
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
    }
    
    private class func writePrevious(appIds: [Int], domain: String?) {
        
        func commute(appId: Int, listType: ListType, index: Int, domainObj: Domain?) {
            guard let domainObj = domainObj else { return }
            if listType == .prevTrustedList {
                domainObj.previouslyTrustedTrackers.remove(at: index)
                domainObj.trustedTrackers.append(appId)
            }
            else if listType == .prevRestrictedList {
                domainObj.previouslyRestrictedTrackers.remove(at: index)
                domainObj.restrictedTrackers.append(appId)
            }
            else if listType == .trustedList {
                domainObj.trustedTrackers.remove(at: index)
                domainObj.previouslyTrustedTrackers.append(appId)
            }
            else if listType == .restrictedList {
                domainObj.restrictedTrackers.remove(at: index)
                domainObj.previouslyRestrictedTrackers.append(appId)
            }
        }
        
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
            
            for appId in appIds {
                let (_, currentListInfo)  = currentState(appId: appId, domainObj: domainObj, realm: realm)
                let (prevState, prevListInfo) = previousState(appId: appId, domainObj: domainObj, realm: realm)
                
                //take care of page state change
                if let (prevListType, prevIndex) = prevListInfo, let (currentListType, currentIndex) = currentListInfo {
                    if !(prevListType == .prevTrustedList && currentListType == .trustedList) && !(prevListType == .prevRestrictedList && currentListType == .restrictedList){
                        // makes sure we don't work on the same lists twice. Example: .trustedList and .prevTrustedList.
                        // working on the same lists could mess up things. We could be removing at the wrong index.
                        commute(appId: appId, listType: prevListType, index: prevIndex, domainObj: domainObj)
                        commute(appId: appId, listType: currentListType, index: currentIndex, domainObj: domainObj)
                    }
                    else {
                        // I don't need to make changes. Example: prevState = trusted && currentState = trusted. No need to commute them
                    }
                }
                else if let (prevListType, prevIndex) = prevListInfo {
                    commute(appId: appId, listType: prevListType, index: prevIndex, domainObj: domainObj)
                }
                else if let (listType, index) = currentListInfo {
                    commute(appId: appId, listType: listType, index: index, domainObj: domainObj)
                }
                
                //take care of global state change
                if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
                    let ps = trackerState.previousState
                    trackerState.previousState = trackerState.state
                    trackerState.state = ps
                    trackerStatesToUpdate.append(trackerState)
                }
                
                if prevState == .empty {
                    TrackerStateStore.shared.blockedTrackers.remove(appId)
                }
                else if prevState == .blocked {
                    TrackerStateStore.shared.blockedTrackers.insert(appId)
                }
            }
            
            realm.add(trackerStatesToUpdate, update: true)
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
    
    private class func setDomainState(appIds: [Int], domain: String, state: TrackerUIState, realm: Realm) {
        let domainObj: Domain
        
        if let d = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
            domainObj = d
        }
        else {
            domainObj = Domain()
            domainObj.name = domain
            realm.add(domainObj)
        }
        
        //moves the current state to the previous state
        for appId in appIds {
            if let trustedIndex = domainObj.trustedTrackers.index(of: appId) {
                domainObj.trustedTrackers.remove(at: trustedIndex)
                domainObj.previouslyTrustedTrackers.append(appId)
                if let prevRestrictedIndex = domainObj.previouslyRestrictedTrackers.index(of: appId) {
                    domainObj.previouslyRestrictedTrackers.remove(at: prevRestrictedIndex)
                }
            }
            else if let restrictedIndex = domainObj.restrictedTrackers.index(of: appId) {
                domainObj.restrictedTrackers.remove(at: restrictedIndex)
                domainObj.previouslyRestrictedTrackers.append(appId)
                if let prevTrustedIndex = domainObj.previouslyTrustedTrackers.index(of: appId) {
                    domainObj.previouslyTrustedTrackers.remove(at: prevTrustedIndex)
                }
            }
            else {
                if let prevTrustedIndex = domainObj.previouslyTrustedTrackers.index(of: appId) {
                    domainObj.previouslyTrustedTrackers.remove(at: prevTrustedIndex)
                }
                
                if let prevRestrictedIndex = domainObj.previouslyRestrictedTrackers.index(of: appId) {
                    domainObj.previouslyRestrictedTrackers.remove(at: prevRestrictedIndex)
                }
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
