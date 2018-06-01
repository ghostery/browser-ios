//
//  GhosteryBlockListHelper.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import WebKit


class ChangeCoordinator {
    static let shared = ChangeCoordinator()
    
    var dict: [BlockListIdentifier: Set<JSONIdentifier>] = [:]
    
    func haveIdsChanged(forBlockId: BlockListIdentifier, domain: String?) -> Bool {
        let ids = AntitrackingJSONIdentifiers.jsonIdentifiers(forBlockListId: forBlockId, domain: domain)
        let result: Bool
        if let jsonIds = dict[forBlockId] {
            result = jsonIds != ids
        }
        else {
            result = false
        }
        dict[forBlockId] = ids
        return result
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
        
        for id in forIdentifiers {
            let idsChanged = ChangeCoordinator.shared.haveIdsChanged(forBlockId: id, domain: domain)
            dispatchGroup.enter()
            listStore?.lookUpContentRuleList(forIdentifier: id) { (ruleList, error) in
                if let ruleList = ruleList, !idsChanged {
                    debugPrint("CACHE: did find list for identifier = \(id) AND ids haven't changed")
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
            debugPrint("finished loading list for id = \(id)")
            return list
        case .error(let error):
            debugPrint("error for id = \(id) | ERROR = \(error.debugDescription)")
            return nil
        case .noResult:
            debugPrint("no result for id = \(id)")
            return nil
        }
    }
}
