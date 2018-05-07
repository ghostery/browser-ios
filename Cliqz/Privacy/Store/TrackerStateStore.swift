//
//  TrackerStateStore.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RealmSwift

class TrackerState: Object {
    @objc dynamic var appId: Int = -1
    @objc dynamic var state: Int = 0 //0 none, 1 trusted, 2 restricted, 3 blocked
    
    override static func primaryKey() -> String? {
        return "appId"
    }
    
    var translatedState: TrackerStateEnum {
        switch state {
        case 0:
            return .none
        case 1:
            return .trusted
        case 2:
            return .restricted
        case 3:
            return .blocked
        default:
            return .none
        }
    }
}

enum TrackerStateEnum {
    case none
    case trusted
    case restricted
    case blocked
}

class TrackerStateStore: NSObject {
    
    class func getTrackerState(appId: Int) -> TrackerState? {
        let realm = try! Realm()
        if let trackerState = realm.object(ofType: TrackerState.self, forPrimaryKey: appId) {
            return trackerState
        }
        return nil
    }
    
    class func createTrackerState(appId: Int, state: TrackerStateEnum = .none) -> TrackerState {
        
        let realm = try! Realm()
        let trackerState = TrackerState()
        trackerState.appId = appId
        trackerState.state = intForState(state: state)

        try! realm.write {
            realm.add(trackerState)
        }
        
        return trackerState
    }
    
    class func change(trackerState: TrackerState, toState: TrackerStateEnum) {
        let realm = try! Realm()
        do {
            try realm.write {
                trackerState.state = intForState(state: toState)
                realm.add(trackerState, update: true)
            }
        }
        catch {
            debugPrint("could not change state of trackerState")
        }
    }
    
    private class func intForState(state: TrackerStateEnum) -> Int {
        switch state {
        case .none:
            return 0
        case .trusted:
            return 1
        case .restricted:
            return 2
        case .blocked:
            return 3
        }
    }
}
