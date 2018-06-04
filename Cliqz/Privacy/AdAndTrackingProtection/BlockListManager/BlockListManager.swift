//
//  GhosteryBlockListHelper.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import WebKit

final class BlockListManager {
    
    static let shared = BlockListManager()
    
    fileprivate let loadQueue: OperationQueue = OperationQueue()
    
    init() {
        loadQueue.maxConcurrentOperationCount = 1
        loadQueue.qualityOfService = .utility
    }
    
    func getBlockLists(forIdentifiers: [BlockListIdentifier], type: BlockListType, domain: String?, hitCache: Bool, callback: @escaping ([WKContentRuleList]) -> Void) {
        
        var returnList = [WKContentRuleList]()
        let dispatchGroup = DispatchGroup()
        let listStore = WKContentRuleListStore.default()

        for id in forIdentifiers {
            dispatchGroup.enter()
            
            if hitCache {
                listStore?.lookUpContentRuleList(forIdentifier: id) { (ruleList, error) in
                    if let ruleList = ruleList {
                        debugPrint("CACHE: FOUND list for identifier = \(id)")
                        returnList.append(ruleList)
                        dispatchGroup.leave()
                    }
                    else {
                        debugPrint("CACHE: did NOT find list for identifier = \(id)")
                        self.loadFromDisk(id: id, type: type, domain: domain, completion: { (list) in
                            if let list = list {
                                returnList.append(list)
                            }
                            dispatchGroup.leave()
                        })
                    }
                }
            }
            else {
                self.loadFromDisk(id: id, type: type, domain: domain, completion: { (list) in
                    if let list = list {
                        returnList.append(list)
                    }
                    dispatchGroup.leave()
                })
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            callback(returnList)
        }
    }
    
    private func loadFromDisk(id: String, type: BlockListType, domain: String?, completion: @escaping (WKContentRuleList?) -> Void) {
        if let json = BlockListFileManager.shared.json(forIdentifier: id, type: type, domain: domain) {
            debugPrint("Load from disk: will compile list for identifier = \(id)")
            let operation = CompileOperation(identifier: id, json: json)
            
            operation.completionBlock = {
                completion(self.handleOperationResult(result: operation.result, id: id))
            }
            
            self.loadQueue.addOperation(operation)
        }
        else {
            completion(nil)
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
