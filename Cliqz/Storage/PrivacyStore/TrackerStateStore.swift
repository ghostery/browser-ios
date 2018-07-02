//
//  TrackerStateStore.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RealmSwift

public class TrackerState: Object {
    @objc dynamic var appId: Int = -1
    @objc dynamic var state: Int = 0 //0 none, 1 blocked
    @objc dynamic var previousState: Int = 0 //none, 1 blocked
    
    override public static func primaryKey() -> String? {
        return "appId"
    }
    
    public var translatedState: TrackerStateEnum {
        switch state {
        case 0:
            return .empty
        case 1:
            return .blocked
        default:
            return .empty
        }
    }
    
    public var prevTranslatedState: TrackerStateEnum {
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

public enum TrackerStateEnum {
    case empty
    case blocked
}

public class TrackerStateStore: NSObject {
    
    public static let shared = TrackerStateStore()
    
    public var blockedTrackers: Set<Int> = Set()
    
    public func populateBlockedTrackers() {
        let realm = try! Realm()
        let states = realm.objects(TrackerState.self)
        for state in states {
            if state.translatedState == .blocked {
                blockedTrackers.insert(state.appId)
            }
        }
    }
    
    @discardableResult public class func createTrackerState(appId: Int) -> TrackerState? {
        return write(appId: appId, state: nil)
    }
    
    public class func change(appId: Int, toState: TrackerStateEnum, completion: (() -> Void)? = nil) {
        write(appId: appId, state: toState)
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
    
    @discardableResult private class func write(appId: Int, state: TrackerStateEnum?) -> TrackerState? {
        
        let realm = try! Realm()
        
        guard realm.isInWriteTransaction == false else { return nil } //avoid exceptions
        
        realm.beginWrite()
        
        var returnState: TrackerState? = nil
        
        if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            if let s = state {
                trackerState.previousState = trackerState.state
                trackerState.state = intForState(state: s)
                realm.add(trackerState, update: true)
                returnState = trackerState
            }
            else {
                realm.cancelWrite()
                return nil
            }
        }
        else {
            let s = state == nil ? .empty : state!
            let trackerState = TrackerState()
            trackerState.appId = appId
            trackerState.state = intForState(state: s)
            trackerState.previousState = intForState(state: .empty)
            realm.add(trackerState)
            returnState = trackerState
        }
        
        if state == .empty {
            TrackerStateStore.shared.blockedTrackers.remove(appId)
        }
        else if state == .blocked {
            TrackerStateStore.shared.blockedTrackers.insert(appId)
        }
        
        do {
            try realm.commitWrite()
            return returnState
        }
        catch {
            debugPrint("could not change state of trackerState")
            return nil
        }
        
    }
    
    private class func intForState(state: TrackerStateEnum) -> Int {
        switch state {
        case .empty:
            return 0
        case .blocked:
            return 1
        }
    }
}
