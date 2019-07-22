//
//  JSBridge.swift
//  Client
//
//  Created by Sam Macbeth on 21/02/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import React

@objc(JSBridge)
class JSBridge : RCTEventEmitter {
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

	enum Action: String {
		case cleanData = "insights:clearData"
	}

    public typealias Callback = (NSDictionary) -> Void
    private typealias ActionArgs = Array<Any>
    
    var registeredActions: Set<String> = [] {
        didSet {
            registeredActionsChanged()
        }
    }
    
    private var missedActions: Dictionary<String, [ActionArgs]> = [:]
    
    var actionCounter: NSInteger = 0
    // cache for responses from js
    var replyCache = [NSInteger: NSDictionary]()
    // semaphores waiting for replies from js
    var eventSemaphores = [NSInteger: DispatchSemaphore]()
    // callbacks waiting for replies from js
    var eventCallbacks = [NSInteger: Callback]()
    // Dictionary of actions waiting for a function to be registered before executing
    var awaitingRegistration = [String: Array<(Array<Any>, Callback)>]()
    
    // serial queue for access to eventSemaphores and eventCallbacks
    fileprivate let semaphoresDispatchQueue = DispatchQueue(label: "com.cliqz.jsbridge.sync", attributes: [])
    // serial queue for access to actionCounter
    fileprivate let lockDispatchQueue = DispatchQueue(label: "com.cliqz.jsbridge.lock", attributes: [])
    // dispatch queue for executing action callbacks
    fileprivate let callbackDispatchQueue = DispatchQueue(label: "com.cliqz.jsbridge.callback", attributes: DispatchQueue.Attributes.concurrent)
    
    let ACTION_TIMEOUT : Int64 = 200000000 // 200ms
    let requestRandomSeedEventId = "requestRandomSeed"
    
    public override init() {
        super.init()
    }
    
    open override static func moduleName() -> String! {
        return "JSBridge"
    }
    
    override open func supportedEvents() -> [String]! {
        // TODO chrmod: clean native bridge
        return ["action", "callAction", "publishEvent"]
    }

    override open func constantsToExport() -> [AnyHashable : Any]! {
        return ["events": ["openUrl",
                           "mobile-pairing:openTab",
                           "mobile-pairing:downloadVideo",
                           "mobile-pairing:pushPairingData",
                           "mobile-pairing:notifyPairingError",
                           "mobile-pairing:notifyPairingSuccess"]
        ]
    }
    
    fileprivate func nextActionId() -> NSInteger {
        var nextId : NSInteger = 0
        lockDispatchQueue.sync {
            self.actionCounter += 1
            nextId = self.actionCounter
        }
        return nextId
    }

    /// Call an action over the JSBridge and discard the result.
    ///
    /// - parameter functionName: String name of the function to call
    /// - parameter args:         arguments to pass to the function
    open func callAction(_ functionName: String, args: Array<Any>) {
        self.callAction(functionName, args: args) { result -> () in
            if let error = result["error"] as? [[String: Any]] {
                debugPrint("Error calling action \(functionName): \(error)")
            }
        }
    }

    @objc(getConfig:reject:)
    func getConfig(resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        if SettingsPrefs.shared.isLumenDefaultSearchEngine {
            UserPreferences.instance.showSearchOnboarding = false
        }
        resolve(["onboarding": UserPreferences.instance.showSearchOnboarding])
    }
    
    /// Call an action over the JSBridge and execute a callback with the result. Invokation of the callback is
    /// not guaranteed, for example if the function is never registered. Unlike the synchronous version, this
    /// function does not return an error for unregistered functions, instead caching the args and re-triggering
    /// the action once registration occurs.
    ///
    /// - parameter functionName: String name of the function to call
    /// - parameter args:         arguments to pass to the function
    /// - parameter callback:     Callback to invoke with the result
    open func callAction(_ functionName: String, args: Array<Any>, callback: @escaping Callback) {
        guard self.registeredActions.contains(functionName) else {
            lockDispatchQueue.sync {
                if self.awaitingRegistration[functionName] == nil {
                    self.awaitingRegistration[functionName] = []
                }
                self.awaitingRegistration[functionName]! += [(args, callback)]
            }
            return
        }
        
        let actionId = nextActionId()
        
        semaphoresDispatchQueue.sync {
            self.eventCallbacks[actionId] = callback
        }
        // only send event - callback is handled in action reply
        self.sendEvent(withName: "action", body: ["id": actionId, "action": functionName, "args": args])
        
    }
    
    /// Publish an event to Javascript over the JSBridge
    ///
    /// - parameter eventName: String name of event
    /// - parameter args:      Array args to pass with the event
    open func publishEvent(_ eventName: String, args: Array<Any>) {
        self.sendEvent(withName: "publishEvent", body: ["event": eventName, "args": args])
    }
    
    @objc(replyToAction:result:)
    func replyToAction(_ actionId: NSInteger, result: NSDictionary) {
        semaphoresDispatchQueue.async {
            // we should find either a semaphore or a callback for this action
            if let sem = self.eventSemaphores[actionId] {
                // place response in cache and signal on this semaphore
                self.replyCache[actionId] = result
                sem.signal()
            } else if let callback = self.eventCallbacks[actionId] {
                self.callbackDispatchQueue.async {
                    callback(result)
                }
                self.eventCallbacks[actionId] = nil
            }
        }
    }
    
    @objc(registerAction:)
    func registerAction(_ actionName: String) {
        self.registeredActions.insert(actionName)
        
        // check for actions waiting to be executed
        lockDispatchQueue.async {
            if let queued = self.awaitingRegistration[actionName] {
                // trigger each waiting action
                queued.forEach { (args, callback) in
                    self.callbackDispatchQueue.async(execute: {
                        self.callAction(actionName, args: args, callback: callback)
                    })
                }
                self.awaitingRegistration[actionName] = []
            }
        }
    }
    
    //Javascript -> Native
    @objc(pushEvent:data:)
    func pushEvent(eventId: NSString, data: NSArray) {
        DispatchQueue.main.async() {
            let name: String = eventId as String
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: name), object: data.count > 0 ? data[0] : nil, userInfo: nil)
        }
    }
    
    private func registeredActionsChanged() {
        for key in missedActions.keys {
            if registeredActions.contains(key), let arguments = missedActions[key] {
                //make sure I remove the arguments before callAction
                //if the function is not registered they will be added again.
                //this avoids duplicates, and keeps memory clean
                missedActions.removeValue(forKey: key)
                for args in arguments {
                    debugPrint("Calling action again: \(key)")
                    callAction(key, args: args)
                }
            }
        }
    }
}
