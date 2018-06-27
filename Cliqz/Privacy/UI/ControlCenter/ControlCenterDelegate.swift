//
//  ControlCenterDelegate.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

extension ControlCenterModel: ControlCenterDelegateProtocol {
    
    
    private func getOrCreateDomain(domain: String) -> Domain {
        //if we have done anything with this domain before we will have something in the DB
        //otherwise we need to create it
        if let domainO = DomainStore.get(domain: domain) {
            return domainO
        } else {
            return DomainStore.create(domain: domain)
        }
    }
    
    func changeState(category: String, tableType: TableType, state: TrackerUIState, section: Int) {
        guard let domainStr = self.domainStr else { return }
        
        let trackers: [Int]
        if tableType == .page {
            trackers = (TrackerList.instance.trackersByCategory(domain: domainStr)[category] ?? []).map({ (app) -> Int in
                return app.appId
            })
        }
        else {
            trackers = (TrackerList.instance.appsByCategory[category] ?? []).map({ (app) -> Int in
                return app.appId
            })
        }
        
        trackers.forEach { (appId) in
            self.changeState(appId: appId, state: state, section: section)
        }
        
    }
    
    func chageSiteState(to: DomainState) {
        guard let domainStr = self.domainStr else { return }
        
        let domainObj: Domain
        domainObj = getOrCreateDomain(domain: domainStr)
        DomainStore.changeState(domain: domainObj, state: to)
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        let apps = TrackerList.instance.detectedTrackersForPage(domainStr)
        for app in apps {
            if to == .empty {
                DomainStore.remove(appId: app.appId, domain: domainObj, list: .restrictedList)
                DomainStore.remove(appId: app.appId, domain: domainObj, list: .trustedList)
            }
            else if to == .trusted {
                DomainStore.add(appId: app.appId, domain: domainObj, list: .trustedList)
            }
            else if to == .restricted {
                DomainStore.add(appId: app.appId, domain: domainObj, list: .restrictedList)
            }
        }
    }
    
    func pauseGhostery(paused: Bool, time: Date) {
        paused ? UserPreferences.instance.pauseGhosteryDate = time : (UserPreferences.instance.pauseGhosteryDate = Date(timeIntervalSince1970: 0))
        UserPreferences.instance.writeToDisk()
    }
    
    func turnGlobalAntitracking(on: Bool) {
        on ? UserPreferences.instance.antitrackingMode = .blockAll : (UserPreferences.instance.antitrackingMode = .blockSomeOrNone)
        UserPreferences.instance.writeToDisk()
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
    }
    
    func turnGlobalAdblocking(on: Bool) {
        on ? UserPreferences.instance.adblockingMode = .blockAll : (UserPreferences.instance.adblockingMode = .blockNone)
        UserPreferences.instance.writeToDisk()
    }
    
    func changeState(appId: Int, state: TrackerUIState, section: Int) {
        if let trakerListApp = TrackerList.instance.apps[appId] {
            
            invalidateStateImageCache(section: section)
            invalidateBlockedCountCache(section: section)
            
            if state == .blocked {
                TrackerStateStore.change(appId: trakerListApp.appId, toState: .blocked)
            }
            else if state == .empty {
                TrackerStateStore.change(appId: trakerListApp.appId, toState: .empty)
            }
            
            if state == TrackerUIState.trusted || state == TrackerUIState.empty {
                UserPreferences.instance.antitrackingMode = .blockSomeOrNone
                UserPreferences.instance.writeToDisk()
            }
            
            if let domainStr = self.domainStr {
                let domainObj = getOrCreateDomain(domain: domainStr)
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
        }
        else {
            debugPrint("PROBLEM -- trackerState does not exist for appId = \(appId)!")
        }
    }
}
