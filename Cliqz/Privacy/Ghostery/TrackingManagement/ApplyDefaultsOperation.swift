//
//  ApplyDefaultsOperation.swift
//  Client
//
//  Created by Tim Palade on 5/28/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

final class ApplyDefaultsOperation: Operation {
    
    private var _executing: Bool = false
    override var isExecuting: Bool {
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
    override var isFinished: Bool {
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
    
    override func main() {
        self.isExecuting = true
        for app in TrackerList.instance.globalTrackerList() {
            if CategoriesHelper.categoriesBlockedByDefault.contains(app.category) {
                TrackerStateStore.change(trackerState: app.state, toState: .blocked)
            }
        }
        self.isFinished = true
    }
}
