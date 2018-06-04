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
}

public enum TrackerStateEnum {
    case empty
    case blocked
}

public class TrackerStateStore: NSObject {
    
    public class func getTrackerState(appId: Int) -> TrackerState? {
        let realm = try! Realm()
        if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            return trackerState
        }
        return nil
    }
    
    @discardableResult public class func createTrackerState(appId: Int, state: TrackerStateEnum = .empty) -> TrackerState {
        
        let realm = try! Realm()
        let trackerState = TrackerState()
        trackerState.appId = appId
        trackerState.state = intForState(state: state)

        try! realm.write {
            realm.add(trackerState)
        }
        
        return trackerState
    }
    
    public class func change(appId: Int, toState: TrackerStateEnum, completion: (() -> Void)? = nil) {
        let realm = try! Realm()
        do {
            try realm.write {
                if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
                    trackerState.state = intForState(state: toState)
                    realm.add(trackerState, update: true)
                }
                else {
                    let trackerState = TrackerState()
                    trackerState.appId = appId
                    trackerState.state = intForState(state: toState)
                    realm.add(trackerState)
                }
                completion?()
            }
        }
        catch {
            debugPrint("could not change state of trackerState")
            completion?()
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
