//
//  SearchEnginesModule.swift
//  Client
//
//  Created by Mahmoud Adam on 9/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import React

@objc(SearchEnginesModule)
class SearchEnginesModule: RCTEventEmitter {
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(getSearchEngines:reject:)
    func getSearchEngines(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        
        DispatchQueue.main.async {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                if let searchEngines = appDel.profile?.searchEngines.orderedEngines {
                    var engines = [[String: Any]]()
                    
                    for i in 0..<searchEngines.count {
                        let searchEngine = searchEngines[i].toDictionary(isDefault: i==0)
                        engines.append(searchEngine)
                    }
                    resolve(engines)
                    return
                } else {
                    reject("SeachEngineError", "Could not retrieve search engines", nil)
                }
            } else {
                reject("AppError", "Could not find AppDelegate", nil)
            }
            
        }
    }
}
