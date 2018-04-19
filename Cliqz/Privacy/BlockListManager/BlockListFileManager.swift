//
//  BlockListFileManager.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

final class BlockListFileManager {
    
    typealias BugID = String
    typealias BugJson = String
    
    static let ghosteryBlockListSplit = "ghostery_content_blocker_split"
    static let ghosteryBlockListNotSplit = "ghostery_content_blocker"
    
    private let ghosteryBlockDict: [BugID:BugJson]
    
    init() {
        ghosteryBlockDict = BlockListFileManager.parseGhosteryBlockList()
    }
    
    func json(forIdentifier: String) -> String? {
        
        func loadJson(path: String) -> String {
            guard let jsonFileContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { fatalError("Rule list for \(forIdentifier) doesn't exist!") }
            return jsonFileContent
        }
        
        //first look in the ghostery list
        if let json = ghosteryBlockDict[forIdentifier] {
            return json
        }
        
        //then look in the bundle
        if forIdentifier.contains("adblocker_") {
            if forIdentifier.contains("exceptions"), let path = Bundle.main.path(forResource: forIdentifier, ofType: "json", inDirectory: "AdBlocker") {
                return loadJson(path: path)
            }
            else if let path = Bundle.main.path(forResource: forIdentifier, ofType: "json", inDirectory: "AdBlocker/Chunks") {
                return loadJson(path: path)
            }
        }
        else if let path = Bundle.main.path(forResource: forIdentifier, ofType: "json") {
            return loadJson(path: path)
        }
        
        return nil
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
