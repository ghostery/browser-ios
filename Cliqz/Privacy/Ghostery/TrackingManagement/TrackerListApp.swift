//
//  TrackerListApp.swift
//  GhosteryBrowser
//
//  Created by Joe Swindler on 2/17/16.
//  Copyright © 2016 Ghostery. All rights reserved.
//

import Foundation

@objc class TrackerListApp : NSObject {
    var appId: Int
    var name: String = ""
    var category: String = ""
    var tags = [Int]()
    var state: TrackerState
    
    init(id: Int, jsonData: [String: AnyObject]) {
        self.appId = id
        
        if let appName = jsonData["name"] as? String {
            name = appName
        }
        
        if let appCategory = jsonData["cat"] as? String {
            category = appCategory
        }
        
        if let appTags = jsonData["tags"] as? [NSNumber] {
            for appTag in appTags {
                tags.append(appTag.intValue)
            }
        }
        
        if let state = TrackerStateStore.getTrackerState(appId: appId) {
            self.state = state
        }
        else {
            let state = TrackerStateStore.createTrackerState(appId: appId, state: .none)
            self.state = state
        }
    }
    
    func printContents() -> String {
        var output = "\n id: \(appId)\n name: \(name)\n category: \(category)\n"
        if tags.count > 0 {
            output += " tags: "
            for tag in tags {
                output += "\(tag),"
            }
            output += "\n"
        }

        return output
    }
}
