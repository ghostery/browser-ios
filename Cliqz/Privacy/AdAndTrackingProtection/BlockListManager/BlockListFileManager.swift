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
    
    static let shared = BlockListFileManager()
    
    private var ghosteryBlockDict: [BugID:BugJson]? = nil
    
    func json(forIdentifier: BlockListIdentifier, type: BlockListType, domain: String?) -> String? {
        
        //In the case type == .adblocker, the jsonIdentifiers are the same as the blockListIdentifiers
        //In the case type == .antitracking, the blockListIdentifiers need to be mapped to jsonIdentifiers
        //Then merge all the small json block lists into a big one.
        
        func loadJson(path: String) -> String {
            guard let jsonFileContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { fatalError("Rule list for \(forIdentifier) doesn't exist!") }
            return jsonFileContent
        }
        
        if forIdentifier.contains("adblocker_"), let path = Bundle.main.path(forResource: forIdentifier, ofType: "json", inDirectory: "AdBlocker/Chunks") {
            return loadJson(path: path)
        }
        
        //then look in the bundle
        if let path = Bundle.main.path(forResource: forIdentifier, ofType: "json") {
            return loadJson(path: path)
        }
        
        if type == .antitracking {
            let jsonIdentifiers = AntitrackingJSONIdentifiers.jsonIdentifiers(forBlockListId: forIdentifier, domain: domain)
            return self.assembleJSON(jsonIds: jsonIdentifiers)
        }
        
        debugPrint("DISK: json not found for identifier = \(forIdentifier)")
        return nil
    }
    
//    class private func assembleJSON(jsonIds: Set<JSONIdentifier>) -> String? {
//        guard jsonIds.count > 0 else { return nil }
//        let path = URL(fileURLWithPath: Bundle.main.path(forResource: ghosteryBlockListSplit, ofType: "json")!)
//        guard let jsonFileContent = try? Data.init(contentsOf: path) else { fatalError("Rule list for \(ghosteryBlockListSplit) doesn't exist!") }
//
//        if var jsonObject = (try? JSONSerialization.jsonObject(with: jsonFileContent, options: [])) as? [String: Any] {
//
//            var json_string = "["
//
//            for key in jsonObject.keys where jsonIds.contains(key) {
//                if let value_dict = jsonObject[key] as? [[String: Any]],
//                    let json_data = try? JSONSerialization.data(withJSONObject: value_dict, options: []),
//                    let blocklist = String.init(data: json_data, encoding: String.Encoding.utf8), blocklist.count > 0
//                {
//                    //remove [ at the beginning and ] at the end
//                    json_string += (blocklist.substring(with: blocklist.index(after: blocklist.startIndex)..<blocklist.index(before: blocklist.endIndex)) + ",")
//                }
//            }
//
//            if json_string.count > 1 {
//                json_string.removeLast()
//                json_string += "]"
//                return json_string
//            }
//        }
//
//        return nil
//    }
    
    private func assembleJSON(jsonIds: Set<JSONIdentifier>) -> String? {
        guard jsonIds.count > 0 else { return nil }
        
        if ghosteryBlockDict == nil {
            ghosteryBlockDict = BlockListFileManager.parseGhosteryBlockList()
        }
        
        var json_string = "["

        for id in jsonIds {
            if let blocklist = ghosteryBlockDict?[id]
            {
                //remove [ at the beginning and ] at the end
                json_string += (blocklist.substring(with: blocklist.index(after: blocklist.startIndex)..<blocklist.index(before: blocklist.endIndex)) + ",")
            }
        }

        if json_string.count > 1 {
            json_string.removeLast()
            json_string += "]"
            return json_string
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
