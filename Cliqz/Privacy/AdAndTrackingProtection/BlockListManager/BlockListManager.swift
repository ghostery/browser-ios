//
//  GhosteryBlockListHelper.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import WebKit
import Storage

class ChangeCoordinator {
    static let shared = ChangeCoordinator()
    
    var last_global: PersistentSet<Int> = PersistentSet(id: "ChangeCoordinatorLastGlobal")
    
    class func generateGlobal(domain: String?) -> Set<Int> {
        
        var specific2domainRestricted: Set<Int> = Set()
        var specific2domainTrusted: Set<Int> = Set()
        
        var global: Set<Int> = Set()
        for app in TrackerList.instance.globalTrackerList() {
            if app.state(domain: domain) == .blocked {
                global.insert(app.appId)
            }
        }
        
        if let domainStr = domain, let domainObj = DomainStore.get(domain: domainStr) {
            specific2domainTrusted = Set(domainObj.trustedTrackers)
            specific2domainRestricted = Set(domainObj.restrictedTrackers)
        }
        
        global.formUnion(specific2domainRestricted)
        global.subtract(specific2domainTrusted)
        
        return global
    }
    
    func identifiersWithChanges(domain: String?) -> Set<BlockListIdentifier> {
        let global = ChangeCoordinator.generateGlobal(domain: domain)
        let appIdsChanged = last_global.symmetricDifference(global)
        last_global.replaceWith(set: global)
        var categories: Set<BlockListIdentifier> = Set()
        for appId in appIdsChanged {
            if let app = TrackerList.instance.apps[appId] {
                categories.insert(app.category)
            }
        }
        return categories
    }
}

final class BlockListManager {
    
    static let shared = BlockListManager()
    
    fileprivate let loadQueue: OperationQueue = OperationQueue()
    
    init() {
        loadQueue.maxConcurrentOperationCount = 1
        loadQueue.qualityOfService = .utility
    }
    
    func getBlockLists(forIdentifiers: [BlockListIdentifier], type: BlockListType, domain: String?, callback: @escaping ([WKContentRuleList]) -> Void) {
        
        var returnList = [WKContentRuleList]()
        let dispatchGroup = DispatchGroup()
        let listStore = WKContentRuleListStore.default()
        var blfm: BlockListFileManager? = nil
        //ask for categories changed here
        let idsWithChanges = ChangeCoordinator.shared.identifiersWithChanges(domain: domain)
        for id in forIdentifiers {
            dispatchGroup.enter()
            listStore?.lookUpContentRuleList(forIdentifier: id) { (ruleList, error) in
                if let ruleList = ruleList, !idsWithChanges.contains(id) {
                    debugPrint("CACHE: FOUND list for identifier = \(id) AND ids haven't changed")
                    returnList.append(ruleList)
                    dispatchGroup.leave()
                }
                else {
                    debugPrint("CACHE: did NOT find list for identifier = \(id) OR ids changed")
                    if blfm == nil {
                        blfm = BlockListFileManager()
                    }
                    if let json = blfm!.json(forIdentifier: id, type: type, domain: domain) {
                        debugPrint("CACHE: will compile list for identifier = \(id)")
                        let operation = CompileOperation(identifier: id, json: json)
                        
                        operation.completionBlock = {
                            if let list = self.handleOperationResult(result: operation.result, id: id) {
                                returnList.append(list)
                            }
                            dispatchGroup.leave()
                        }
                        
                        self.loadQueue.addOperation(operation)
                    }
                    else {
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            callback(returnList)
        }
    }
    
    private func handleOperationResult(result: CompileOperation.Result, id: String) -> WKContentRuleList? {
        switch result {
        case .list(let list):
            debugPrint("CompileOperation: finished loading list for id = \(id)")
            return list
        case .error(let error):
            debugPrint("CompileOperation: error for id = \(id) | ERROR = \(error.debugDescription)")
            return nil
        case .noResult:
            debugPrint("CompileOperation: no result for id = \(id)")
            return nil
        }
    }
}
