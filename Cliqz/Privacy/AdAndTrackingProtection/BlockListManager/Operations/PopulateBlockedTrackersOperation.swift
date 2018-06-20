//
//  Populate.swift
//  Client
//
//  Created by Tim Palade on 6/5/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit
import Storage

public class PopulateBlockedTrackersOperation: Operation {
    
    private var _executing: Bool = false
    override public var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            if _executing != newValue {
                willChangeValue(forKey: "isExecuting")
                _executing = newValue
                didChangeValue(forKey: "isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false;
    override public var isFinished: Bool {
        get {
            return _finished
        }
        set {
            if _finished != newValue {
                willChangeValue(forKey: "isFinished")
                _finished = newValue
                didChangeValue(forKey: "isFinished")
            }
        }
    }
    
    override public func main() {
        self.isExecuting = true
        TrackerStateStore.shared.populateBlockedTrackers()
        if TrackerStateStore.shared.blockedTrackers.count == TrackerList.instance.apps.keys.count {
            UserPreferences.instance.antitrackingMode = .blockAll
            UserPreferences.instance.writeToDisk()
        }
        self.isFinished = true
    }
}
