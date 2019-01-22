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
    
    func loadGhosteryJson() {
        self.ghosteryBlockDict = BlockListFileManager.parseGhosteryBlockList()
    }
    
    func json(forIdentifier: BlockListIdentifier, type: BlockListType, domain: String?, completion: @escaping (String?) -> Void) {
        
        //In the case type == .adblocker, the jsonIdentifiers are the same as the blockListIdentifiers
        //In the case type == .antitracking, the blockListIdentifiers need to be mapped to jsonIdentifiers
        //Then merge all the small json block lists into a big one.
        
        func loadJson(path: String) -> String? {
            guard let jsonFileContent = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }//fatalError("Rule list for \(forIdentifier) doesn't exist!") }
            return jsonFileContent
        }
        
        if type == .antitracking {
			// TODO: this Implementation should be improved to take into account all identifiers, and load json from all files instead of only first. I had to add 3rd party cookies blocking rules on top of antitracking list to make it work. Before this improvement if we change antiracking blocklist file we should be carefull to add 3rd party cookies as well
            if forIdentifier == AntitrackingJSONIdentifiers.antitrackingBlockAllIdentifiers().first, let path = Bundle.main.path(forResource: forIdentifier, ofType: "json") {
                //then look in the bundle
                completion(loadJson(path: path))
                return
            }
            else {
                let jsonIdentifiers = AntitrackingJSONIdentifiers.jsonIdentifiers(forBlockListId: forIdentifier, domain: domain)
                self.assembleJSON(jsonIds: jsonIdentifiers, completion: { (json) in
                    completion(json)
                })
                return
            }
        }
        else if forIdentifier.contains("adblockerFile_"), let path = Bundle.main.path(forResource: forIdentifier, ofType: "json", inDirectory: "AdBlocker/Chunks") {
            completion(loadJson(path: path))
            return
        }
        
        completion(nil)
    }
    
    private func assembleJSON(jsonIds: Set<JSONIdentifier>, completion: @escaping (String?) -> Void) {
        
        if jsonIds.count == 0 {
            completion(nil)
            return
        }
        
        DispatchQueue.global(qos: .utility).async {
            var json_string = "["
            
            for id in jsonIds {
                if let blocklist = self.ghosteryBlockDict?[id]
                {
                    json_string += blocklist + ","
                }
            }
            
            if json_string.count > 1 {
                //removes the last comma
                json_string.removeLast()
                json_string += "]"
                completion(json_string)
                return
            }
            
            completion(nil)
        }
    }

    
    class private func parseGhosteryBlockList() -> [BugID:BugJson] {
        let path = URL(fileURLWithPath: Bundle.main.path(forResource: ghosteryBlockListSplit, ofType: "json")!)
        guard let jsonFileContent = try? Data.init(contentsOf: path) else { fatalError("Rule list for \(ghosteryBlockListSplit) doesn't exist!") }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonFileContent, options: [])
        
        var dict: [BugID:BugJson] = [:]
        
        if let id_dict = jsonObject as? [String: Any] {
            //debugPrint("number of keys = \(id_dict.keys.count)")
            for key in id_dict.keys {
                if let value_dict = id_dict[key] as? [[String: Any]],
                    let json_data = try? JSONSerialization.data(withJSONObject: value_dict, options: []),
                    var json_string = String.init(data: json_data, encoding: String.Encoding.utf8)
                {
                    //remove [ at the beginning and ] at the end
                    json_string.removeFirst()
                    json_string.removeLast()
                    dict[key] = json_string
                }
            }
        }
        //debugPrint("number of keys successfully parsed = \(dict.keys.count)")
        return dict
    }
}
