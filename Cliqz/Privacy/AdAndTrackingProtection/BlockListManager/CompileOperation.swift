//
//  CompileOperation.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//
import WebKit

class CompileOperation: Operation {
    let json: String
    let identifier: String
    var result: Result = .noResult
    
    public enum Result {
        case error(Error?)
        case list(WKContentRuleList)
        case noResult
    }
    
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
    
    init(identifier:String ,json: String) {
        self.identifier = identifier
        self.json = json
        super.init()
    }
    
    override func main() {
        self.isExecuting = true
        let listStore = WKContentRuleListStore.default()
        listStore?.compileContentRuleList(forIdentifier: self.identifier, encodedContentRuleList: self.json) { (ruleList, error) in
            if let ruleList = ruleList {
                self.result = Result.list(ruleList)
            }
            else {
                self.result = Result.error(error)
            }
            
            //Throttle load for devices with less than 2gb of memory
            if ProcessInfo.processInfo.physicalMemory < 2000000000 {
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1, execute: {
                    self.isFinished = true
                })
            }
            else {
                self.isFinished = true
            }
        }
    }
}
