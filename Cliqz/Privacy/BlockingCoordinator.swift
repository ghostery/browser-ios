//
//  BlockingCoordinator.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit

enum BlockListType {
    case antitracking
    case adblocker
}

final class BlockingCoordinator {
    
    private var isUpdating = false
    private var shouldUpdateAgain = false
    
    private unowned let webView: WKWebView
    
    private let updateQueue: OperationQueue //only for update calls
    
    init(webView: WKWebView) {
        self.webView = webView
        self.updateQueue = OperationQueue()
        updateQueue.maxConcurrentOperationCount = 1
        updateQueue.underlyingQueue = DispatchQueue.main
    }
    
    //TODO: Make sure that at the time of the coordinatedUpdate, all necessary blocklists are in the cache
    func coordinatedUpdate() {
        debugPrint("Coordinated Update")
        if self.updateQueue.operations.filter({ (op) -> Bool in return !(op.isExecuting  || op.isFinished || op.isCancelled) }).count == 0 {
            debugPrint("Add to Update Queue")
            let updateOp = UpdateOperation(webView: self.webView)
            self.updateQueue.addOperation(updateOp)
        }
    }
}

final class UpdateHelper {
    
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
    
    class func identifiersForAntitracking(domain: String?) -> [String] {
        //logic what to load for antitracking
        if UserPreferences.instance.antitrackingMode == .blockAll {
            return BlockListIdentifiers.antitrackingBlockAllIdentifiers()
        }
        else {
            if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
                if domainObj.translatedState == .restricted {
                    return BlockListIdentifiers.antitrackingBlockAllIdentifiers()
                }
            }
        }
        
        //assemble list of appIds for which blocklists need to loaded
        return BlockListIdentifiers.antitrackingBlockSelectedIdentifiers(domain: domain)
    }
    
    class func identifiersFor(type: BlockListType, domain: String?) -> [String] {
        return type == .antitracking ? identifiersForAntitracking(domain: domain) : BlockListIdentifiers.adblockingIdentifiers()
    }
}

class UpdateOperation: Operation {
    
    private unowned let webView: WKWebView
    
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
    
    init(webView: WKWebView) {
        self.webView = webView
        super.init()
    }
    
    override func main() {
        self.isExecuting = true
        
        var blockLists: [WKContentRuleList] = []
        let dispatchGroup = DispatchGroup()
        let domain = webView.url?.normalizedHost
        for type in UpdateHelper.order {
            if UpdateHelper.featureIsOn(forType: type, domain: domain) {
                //get the blocklists for that type
                dispatchGroup.enter()
                let identifiers = UpdateHelper.identifiersFor(type: type, domain: domain)
                BlockListManager.shared.getBlockLists(forIdentifiers: identifiers, callback: { (lists) in
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
            self.webView.configuration.userContentController.removeAllContentRuleLists()
            blockLists.forEach(self.webView.configuration.userContentController.add)
            debugPrint("BlockLists Loaded")
            self.isFinished = true
        }
    }
}

