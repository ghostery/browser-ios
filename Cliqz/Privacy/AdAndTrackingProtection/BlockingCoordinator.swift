//
//  BlockingCoordinator.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit
import Storage

// There are 2 types of Identifiers that I work with.
typealias BlockListIdentifier = String
typealias JSONIdentifier = String

enum BlockListType: Comparable {
    case antitracking
    case adblocker
    
    static func < (lhs: BlockListType, rhs: BlockListType) -> Bool {
        return lhs == .antitracking && rhs == .adblocker
    }
}

final class GlobalPrivacyQueue {
    fileprivate let queue: OperationQueue
    
    static let shared = GlobalPrivacyQueue()
    
    init() {
        self.queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .utility
    }
    
    func addOperation(_ operation: Operation) {
        self.queue.addOperation(operation)
    }
    
    var operations: [Operation] {
        return self.queue.operations
    }
}

final class BlockingCoordinator {
    
    private var isUpdating = false
    private var shouldUpdateAgain = false
    
    private unowned let webView: WKWebView
    
    class func isAdblockerOn(domain: String?) -> Bool {
        
        #if PAID
        return UserPreferences.instance.isProtectionOn
        #else
        if let domain = domain {
            if let domain = DomainStore.get(domain: domain) {
                let state = domain.translatedAdblockerState()
                if state == .on {
                    return true
                }
                else if state == .off {
                    return false
                }
            }
        }
        return UserPreferences.instance.adblockingMode == .blockAll
        #endif
    }
    
    class func isAntitrackingOn(domain: String?) -> Bool {
        
        #if PAID
        return UserPreferences.instance.isProtectionOn
        #else
        if UserPreferences.instance.pauseGhosteryMode == .paused {
            return false
        }
        
        return true
        #endif
    }
    
    //order in which to load the blocklists
    static let order: [BlockListType] = [.antitracking, .adblocker]
    
    class func featureIsOn(forType: BlockListType, domain: String?) -> Bool {
        return forType == .antitracking ? isAntitrackingOn(domain: domain) : isAdblockerOn(domain: domain)
    }
    
    class func blockIdentifiers(forType: BlockListType, domain: String?, webView: WKWebView?) -> ([BlockListIdentifier], [String: Bool]?) {
        if forType == .antitracking {
            #if PAID
            return (AntitrackingJSONIdentifiers.antitrackingBlockAllIdentifiers(), nil)
            #else
            if UserPreferences.instance.antitrackingMode == .blockAll {
                return (AntitrackingJSONIdentifiers.antitrackingBlockAllIdentifiers(), nil)
            }
            return BlockListIdentifiers.antitrackingIdentifiers(domain: domain, webView: webView)
            #endif
        }
        else {
            return (BlockListIdentifiers.adblockingIdentifiers(), nil)
        }
    }
    
    init(webView: WKWebView) {
        self.webView = webView
    }
    
    //TODO: Make sure that at the time of the coordinatedUpdate, all necessary blocklists are in the cache
    func coordinatedUpdate() {
        
        func opFilter(op: Operation) -> Bool {
            if let operation = op as? UpdateOperation {
                return !(operation.isExecuting  || operation.isFinished || operation.isCancelled)
            }
            return false
        }
        
        DispatchQueue.main.async {
            debugPrint("Coordinated Update")
            if GlobalPrivacyQueue.shared.operations.filter(opFilter).count == 0 {
                debugPrint("Add to Update Queue")
                let updateOp = UpdateOperation(webView: self.webView, domain: self.webView.url?.normalizedHost)
                #if !PAID
                updateOp.addDependency(TrackerList.instance.populateOp)
                #endif
                GlobalPrivacyQueue.shared.addOperation(updateOp)
            }
        }
    }
}
