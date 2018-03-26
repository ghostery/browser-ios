//
//  GhosteryBlockListHelper.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import WebKit

fileprivate let ghosteryBlockListSplit = "ghostery_content_blocker_split"
fileprivate let ghosteryBlockListNotSplit = "ghostery_content_blocker"

final class BlockListManager {
    
    static let shared = BlockListManager()
    
    var loadQueue: OperationQueue? = nil
    
    init() {
        if loadQueue == nil {
            loadQueue = OperationQueue()
            loadQueue?.maxConcurrentOperationCount = 1
            loadQueue?.qualityOfService = .background
        }
    }

    //appIds need to be first translated to bugIds and then loaded.
    func getBlockLists(appIds: [Int], callback: @escaping ([WKContentRuleList]) -> Void) {
        func getBugIds(appIds: [Int]) -> [Int] {
            return appIds.flatMap { (appId) -> [Int] in
                return TrackerList.instance.app2bug[appId] ?? []
            }
        }
        
        let bugIds = getBugIds(appIds: appIds).map { i in String(i) }
        
        self.getBlockLists(forIdentifiers: bugIds) { (lists) in
            callback(lists)
        }
    }
    
    func getBlockLists(forIdentifiers: [String], callback: @escaping ([WKContentRuleList]) -> Void) {
        
        var returnList = [WKContentRuleList]()
        let dispatchGroup = DispatchGroup()
        let listStore = WKContentRuleListStore.default()
        var blfm: BlockListFileManager? = nil
        
        for id in forIdentifiers {
            dispatchGroup.enter()
            listStore?.lookUpContentRuleList(forIdentifier: id) { (ruleList, error) in
                if let ruleList = ruleList {
                    returnList.append(ruleList)
                    dispatchGroup.leave()
                }
                else {
                    debugPrint("did not find list for identifier = \(id)")
                    if blfm == nil {
                        blfm = BlockListFileManager()
                    }
                    self.loadQueue?.addOperation {
                        let json = blfm!.json(forIdentifier: id)
                        listStore?.compileContentRuleList(forIdentifier: id, encodedContentRuleList: json) { (ruleList, error) in
                            guard let ruleList = ruleList else { fatalError("problem compiling \(id)") }
                            returnList.append(ruleList)
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .global()) {
            callback(returnList)
        }
    }
}

final class BlockListIdentifiers {
    
    class func all() -> [String] {
        return allBugIds() + BlockListIdentifiers.antitrackingIdentifiers + BlockListIdentifiers.adblockingIdentifiers
    }
    
    static let antitrackingIdentifiers: [String] = ["ghostery_content_blocker"]
    static let adblockingIdentifiers: [String] = []
    
    //all bug ids in the ghostery file
    class private func allBugIds() -> [String] {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: ghosteryBlockListSplit, ofType: "json")!)
        guard let jsonFileContent = try? Data.init(contentsOf: path) else { fatalError("Rule list for \(ghosteryBlockListSplit) doesn't exist!") }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonFileContent, options: [])
        
        if let id_dict = jsonObject as? [String: Any] {
            return Array(id_dict.keys)
        }
        return []
    }
}

final class BlockListFileManager {
    
    typealias BugID = String
    typealias BugJson = String
    
    private let ghosteryBlockDict: [BugID:BugJson]
    
    init() {
        ghosteryBlockDict = BlockListFileManager.parseGhosteryBlockList()
    }
    
    func json(forIdentifier: String) -> String {
        
        if let json = ghosteryBlockDict[forIdentifier] {
            return json
        }
        //otherwise
        //search the bundle for a json and parse it.
        let path = Bundle.main.path(forResource: forIdentifier, ofType: "json")!
        guard let jsonFileContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { fatalError("Rule list for \(forIdentifier) doesn't exist!") }
        return jsonFileContent
    }
    
    class private func parseGhosteryBlockList() -> [BugID:BugJson] {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: ghosteryBlockListSplit, ofType: "json")!)
        guard let jsonFileContent = try? Data.init(contentsOf: path) else { fatalError("Rule list for \(ghosteryBlockListSplit) doesn't exist!") }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonFileContent, options: [])
        
        var dict: [BugID:BugJson] = [:]
        
        if let id_dict = jsonObject as? [String: Any] {
            debugPrint("number of keys = \(id_dict.keys.count)")
            for key in id_dict.keys {
                if let value_dict = id_dict[key] as? [[String: Any]],
                    let json_data = try? JSONSerialization.data(withJSONObject: value_dict, options: []),
                    let json_string = String.init(data: json_data, encoding: String.Encoding.utf8)
                {
                    dict[key] = json_string
                }
            }
        }
        debugPrint("number of keys successfully parsed = \(dict.keys.count)")
        return dict
    }
}



