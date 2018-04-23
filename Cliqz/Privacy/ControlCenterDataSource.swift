//
//  ControlCenterDataSource.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

protocol ControlCenterDSProtocol {
    func domainString() -> String
    func trackersByCategory() -> Dictionary<String, [TrackerListApp]>
    func globalTrackersByCategory() -> Dictionary<String, [TrackerListApp]>
    func countByCategory() -> Dictionary<String, Int>
    func totalTrackerCount() -> Int
    func isGhosteryPaused() -> Bool
    func isGlobalAntitrackingOn() -> Bool
    func isGlobalAdblockerOn() -> Bool
    func antitrackingCount() -> Int
    func adblockCount() -> Int
}

class ControlCenterDataSource: ControlCenterDSProtocol {
    
    let domainObj: Domain?
    let domainStr: String
    
    init(domain: String) {
        self.domainStr = domain
        self.domainObj = DomainStore.get(domain: domainStr)
    }
    
    func trackersByCategory() -> Dictionary<String, [TrackerListApp]> {
        return TrackerList.instance.trackersByCategory(for: self.domainStr)
    }
    
    func globalTrackersByCategory() -> Dictionary<String, [TrackerListApp]> {
        return TrackerList.instance.trackersByCategory()
    }
    
    func countByCategory() -> Dictionary<String, Int> {
        return TrackerList.instance.countByCategory(domain: self.domainStr)
    }
    
    func domainString() -> String {
        return domainStr
    }
    
    func totalTrackerCount() -> Int {
        return TrackerList.instance.detectedTrackerCountForPage(self.domainStr)
    }
    
    func domainState() -> DomainState {
        if let domain = domainObj {
            return domain.translatedState
        }
        return .none //placeholder
    }
    
    func isGhosteryPaused() -> Bool {
        return false //placeholder
    }
    
    func isGlobalAntitrackingOn() -> Bool {
        return UserPreferences.instance.blockingMode == .all
    }
    
    func isGlobalAdblockerOn() -> Bool {
        return true //placeholder
    }
    
    func antitrackingCount() -> Int {
        return self.totalTrackerCount()
    }
    
    func adblockCount() -> Int {
        return 0 //placeholder
    }
}
