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
    
    //needed to make adblocking loading sequencial
    var previousOp: Operation? = nil
    
    init() {
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
                    //Thread: Main
                    if let ruleList = ruleList {
                        //debugPrint("CACHE: FOUND list for identifier = \(id)")
                        returnList.append(ruleList)
                        dispatchGroup.leave()
                    }
                    else {
                        //debugPrint("CACHE: did NOT find list for identifier = \(id)")
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
                //This needs to be on main due to problems when accessing DB
                //TODO: Solve the problem - They should be solved now. Still need to check if it works.
                DispatchQueue.main.async {
                    self.loadFromDisk(id: id, type: type, domain: domain, completion: { (list) in
                        if let list = list {
                            returnList.append(list)
                        }
                        dispatchGroup.leave()
                    })
                }
            }
        }
        
        dispatchGroup.notify(queue: .global(qos: .utility)) {
            //reset
            self.previousOp = nil
            callback(returnList)
        }
    }
    
    private func loadFromDisk(id: String, type: BlockListType, domain: String?, completion: @escaping (WKContentRuleList?) -> Void) {
        //debugPrint("Load from disk: will compile list for identifier = \(id)")
        BlockListFileManager.shared.json(forIdentifier: id, type: type, domain: domain, completion: { (json) in
            if let json = json {
                let operation = CompileOperation(identifier: id, json: json)
                
                if type == .adblocker {
                    if let prev = self.previousOp {
                        operation.addDependency(prev)
                    }
                    
                    self.previousOp = operation
                }
                
                operation.completionBlock = {
                    completion(self.handleOperationResult(result: operation.result, id: id))
                }
                
                self.loadQueue.addOperation(operation)
            }
            else {
                debugPrint("DISK: json not found for identifier = \(id)")
                completion(nil)
            }
        })
    }
    
    private func handleOperationResult(result: CompileOperation.Result, id: String) -> WKContentRuleList? {
        switch result {
        case .list(let list):
            //debugPrint("CompileOperation: finished loading list for id = \(id)")
            return list
        case .error(let _):
            //debugPrint("CompileOperation: error for id = \(id) | ERROR = \(error.debugDescription)")
            return nil
        case .noResult:
            //debugPrint("CompileOperation: no result for id = \(id)")
            return nil
        }
    }
}

import CoreFoundation

class ParkBenchTimer {
    
    let startTime:Date
    var endTime:Date?
    
    init() {
        startTime = Date()
    }
    
    func stop() {
        endTime = Date()
    }
    
    var duration: Double? {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        } else {
            return nil
        }
    }
}
