//
//  ChangeTrackersOperation.swift
//  Client
//
//  Created by Tim Palade on 9/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Storage

public class ChangeTrackersOperation: Operation {
    
    public enum BlockOption {
        case blockAll
        case unblockAll
    }
    
    var blockOption: BlockOption = .blockAll
    
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
    
    public init(blockOption: BlockOption) {
        super.init()
        self.blockOption = blockOption
    }
    
    override public func main() {
        self.isExecuting = true
        if blockOption == .blockAll {
            TrackerStateStore.change(appIds: TrackerList.instance.appsList.map{app in return app.appId}, toState: .blocked, completion: {
                self.isFinished = true
            })
        }
        else if blockOption == .unblockAll {
            TrackerStateStore.change(appIds: TrackerList.instance.appsList.map{app in return app.appId}, toState: .empty, completion: {
                self.isFinished = true
            })
        }
        else {
            self.isFinished = true
        }
    }
}

