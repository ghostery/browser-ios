//
//  ControlCenterDelegate.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

protocol ControlCenterDelegateProtocol: class {
    func chageSiteState(to: DomainState)
    func pauseGhostery(paused: Bool, time: Date)
    func turnGlobalAntitracking(on: Bool)
    func turnGlobalAdblocking(on: Bool)
    func changeState(appId: Int, state: TrackerStateEnum)
    func changeState(category: String, tableType: TableType, state: TrackerStateEnum)
}

class ControlCenterDelegate: ControlCenterDelegateProtocol {
    
    let domainStr: String
    
    init(url: URL) {
        self.domainStr = url.normalizedHost ?? url.absoluteString
    }
    
    private func getOrCreateDomain() -> Domain {
        //if we have done anything with this domain before we will have something in the DB
        //otherwise we need to create it
        if let domainO = DomainStore.get(domain: self.domainStr) {
            return domainO
        } else {
            return DomainStore.create(domain: self.domainStr)
        }
    }

    func changeState(category: String, tableType: TableType, state: TrackerStateEnum) {
        
        let trackers: [Int]
        if tableType == .page {
            trackers = (TrackerList.instance.trackersByCategory(domain: domainStr)[category] ?? []).map({ (app) -> Int in
                return app.appId
            })
        }
        else {
            trackers = (TrackerList.instance.trackersByCategory()[category] ?? []).map({ (app) -> Int in
                return app.appId
            })
        }
        
        trackers.forEach { (appId) in
            self.changeState(appId: appId, state: state)
        }
        
	}

    func chageSiteState(to: DomainState) {
        let domainObj: Domain
        domainObj = getOrCreateDomain()
        DomainStore.changeState(domain: domainObj, state: to)
        let trackerState: TrackerStateEnum
        if to == .restricted {
            trackerState = .restricted
        }
        else if to == .trusted {
            trackerState = .trusted
        }
        else {
            trackerState = .empty
        }
        
        let apps = TrackerList.instance.detectedTrackersForPage(self.domainStr)
        for app in apps {
            changeState(appId: app.appId, state: trackerState)
        }
    }
    
    func pauseGhostery(paused: Bool, time: Date) {
        paused ? UserPreferences.instance.pauseGhosteryDate = time : (UserPreferences.instance.pauseGhosteryDate = Date(timeIntervalSince1970: 0))
        UserPreferences.instance.writeToDisk()
    }
    
    func turnGlobalAntitracking(on: Bool) {
        on ? UserPreferences.instance.antitrackingMode = .blockAll : (UserPreferences.instance.antitrackingMode = .blockSomeOrNone)
        UserPreferences.instance.writeToDisk()
    }
    
    func turnGlobalAdblocking(on: Bool) {
        on ? UserPreferences.instance.adblockingMode = .blockAll : (UserPreferences.instance.adblockingMode = .blockNone)
        UserPreferences.instance.writeToDisk()
    }
    
    func changeState(appId: Int, state: TrackerStateEnum) {
        if let trakerListApp = TrackerList.instance.apps[appId] {
            TrackerStateStore.change(appId: trakerListApp.appId, toState: state)
            
            if state == .trusted || state == .empty {
                UserPreferences.instance.antitrackingMode = .blockSomeOrNone
                UserPreferences.instance.writeToDisk()
            }
            
            let domainObj = getOrCreateDomain()
            if state == .trusted {
                //disable domain restriction if applicable
                DomainStore.changeState(domain: domainObj, state: .empty)
                //add it to trusted sites
                DomainStore.add(appId: appId, domain: domainObj, list: .trustedList)
                //remove it from restricted if it is there
                DomainStore.remove(appId: appId, domain: domainObj, list: .restrictedList)
            }
            else if state == .restricted {
                //add it to restricted
                DomainStore.add(appId: appId, domain: domainObj, list: .restrictedList)
                //remove from trusted if it is there
                DomainStore.remove(appId: appId, domain: domainObj, list: .trustedList)
            }
            else {
                //disable domain restriction if applicable
                DomainStore.changeState(domain: domainObj, state: .empty)
                //remove from trusted and restricted
                DomainStore.remove(appId: appId, domain: domainObj, list: .trustedList)
                DomainStore.remove(appId: appId, domain: domainObj, list: .restrictedList)
            }
        }
        else {
            debugPrint("PROBLEM -- trackerState does not exist for appId = \(appId)!")
        }
    }
}
