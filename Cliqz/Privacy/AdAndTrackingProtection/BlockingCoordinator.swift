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

enum BlockListType {
    case antitracking
    case adblocker
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
    
    class func isAdblockerOn() -> Bool {
        return UserPreferences.instance.adblockingMode == .blockAll
    }
    
    class func isAntitrackingOn(domain: String?) -> Bool {
        
        if UserPreferences.instance.pauseGhosteryMode == .paused {
            return false
        }
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            return !(domainObj.translatedState == .trusted)
        }
        return true
    }
    
    //order in which to load the blocklists
    static let order: [BlockListType] = [.antitracking, .adblocker]
    
    class func featureIsOn(forType: BlockListType, domain: String?) -> Bool {
        return forType == .antitracking ? isAntitrackingOn(domain: domain) : isAdblockerOn()
    }
    
    class func blockIdentifiers(forType: BlockListType) -> [BlockListIdentifier] {
        if forType == .antitracking {
            if UserPreferences.instance.antitrackingMode == .blockAll {
                return AntitrackingJSONIdentifiers.antitrackingBlockAllIdentifiers()
            }
            return BlockListIdentifiers.antitrackingIdentifiers()
        }
        else {
            return BlockListIdentifiers.adblockingIdentifiers()
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
                GlobalPrivacyQueue.shared.addOperation(updateOp)
            }
        }
    }
}

class UpdateOperation: Operation {
    
    private weak var webView: WKWebView? = nil
    private let domain: String?
    
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
    
    init(webView: WKWebView, domain: String?) {
        self.webView = webView
        self.domain = domain
        super.init()
    }
    
    override func main() {
        self.isExecuting = true
        
        var blockLists: [WKContentRuleList] = []
        let dispatchGroup = DispatchGroup()
        for type in BlockingCoordinator.order {
            if BlockingCoordinator.featureIsOn(forType: type, domain: domain) {
                //get the blocklists for that type
                dispatchGroup.enter()
                let identifiers = BlockingCoordinator.blockIdentifiers(forType: type)
                BlockListManager.shared.getBlockLists(forIdentifiers: identifiers, type: type, domain: domain, callback: { (lists) in
                    blockLists.append(contentsOf: lists)
                    type == .antitracking ? debugPrint("Antitracking is ON") : debugPrint("Adblocking is ON")
                    dispatchGroup.leave()
                })
            }
            else {
                type == .antitracking ? debugPrint("Antitracking is OFF") : debugPrint("Adblocking is OFF")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.webView?.configuration.userContentController.removeAllContentRuleLists()
            if let webView = self.webView {
                blockLists.forEach(webView.configuration.userContentController.add)
                debugPrint("BlockLists Loaded")
            }
            self.isFinished = true
        }
    }
}

