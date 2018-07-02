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
        
        let trackers: [TrackerListApp]
        if let domainStr = self.domainStr {
            trackers = (TrackerList.instance.trackersByCategory(domain: domainStr)[category] ?? [])
        }
        else {
            trackers = (TrackerList.instance.appsByCategory[category] ?? [])
        }
        
        trackers.forEach { (app) in
            self.changeState(appId: app.appId, state: state, section: section)
        }
        
    }
    
    func chageSiteState(to: DomainState) {
        guard let domainStr = self.domainStr else { return }
        
        let domainObj: Domain
        domainObj = getOrCreateDomain(domain: domainStr)
        DomainStore.changeState(domain: domainObj, state: to)
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        let nextState = domainState2TrackerUIState(domainState: to)
        let apps = TrackerList.instance.detectedTrackersForPage(domainStr)
        for app in apps {
            let currentState = app.state(domain: domainStr)
            changeTrackerStateFor(domainObj: domainObj, appId: app.appId, currentState: currentState, nextState: nextState)
            changeGlobalTrackerState(to: nextState, appId: app.appId)
        }
    }
    
    func changeState(appId: Int, state: TrackerUIState, section: Int?) {
        if let trackerListApp = TrackerList.instance.apps[appId] {
            
            if let s = section {
                invalidateStateImageCache(section: s)
                invalidateBlockedCountCache(section: s)
            }
            
            if let domainStr = self.domainStr {
                
                let currentState = trackerListApp.state(domain: domainStr)
                let domainObj = getOrCreateDomain(domain: domainStr)
                
                DomainStore.changeState(domain: domainObj, state: .empty)
                changeTrackerStateFor(domainObj: domainObj, appId: appId, currentState: currentState, nextState: state)
            }
            
            changeGlobalTrackerState(to: state, appId: trackerListApp.appId)
            
            if state == TrackerUIState.trusted || state == TrackerUIState.empty {
                UserPreferences.instance.antitrackingMode = .blockSomeOrNone
                UserPreferences.instance.writeToDisk()
            }
        }
        else {
            debugPrint("PROBLEM -- trackerState does not exist for appId = \(appId)!")
        }
    }
    
    func blockAll() {
        changeAll(state: .blocked)
    }
    
    func unblockAll() {
        changeAll(state: .empty)
    }
    
    func undoAll() {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        let trackers: [TrackerListApp]
        
        var domain: String? = nil
        
        if let d = self.domainStr {
            domain = d
            trackers = TrackerList.instance.detectedTrackersForPage(d)
        }
        else {
            trackers = TrackerList.instance.appsList
        }
        
        for tracker in trackers {
            self.changeState(appId: tracker.appId, state: tracker.prevState(domain: domain), section: nil)
        }
    }
    
    func restoreDefaultSettings() {
        guard self.domainStr == nil else { return }
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        UserPreferences.instance.antitrackingMode = .blockSomeOrNone
        UserPreferences.instance.writeToDisk()
        
        let trackers = TrackerList.instance.appsList
        
        for tracker in trackers {
            if CategoriesHelper.categoriesBlockedByDefault.contains(tracker.category) {
                changeGlobalTrackerState(to: .blocked, appId: tracker.appId)
            }
            else {
                changeGlobalTrackerState(to: .empty, appId: tracker.appId)
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
    
    private func changeAll(state: TrackerUIState) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        let trackers: [TrackerListApp]
        
        if let d = self.domainStr {
            trackers = TrackerList.instance.detectedTrackersForPage(d)
        }
        else {
            trackers = TrackerList.instance.appsList
        }
        
        for tracker in trackers {
            self.changeState(appId: tracker.appId, state: state, section: nil)
        }
    }

    private func changeTrackerStateFor(domainObj: Domain, appId: Int, currentState: TrackerUIState, nextState: TrackerUIState) {
        
        if currentState == .trusted {
            DomainStore.add(appId: appId, domain: domainObj, list: .prevTrustedList)
            DomainStore.remove(appId: appId, domain: domainObj, list: .prevRestrictedList)
        }
        else if currentState == .restricted {
            DomainStore.add(appId: appId, domain: domainObj, list: .prevRestrictedList)
            DomainStore.remove(appId: appId, domain: domainObj, list: .prevTrustedList)
        }
        else {
            DomainStore.remove(appId: appId, domain: domainObj, list: .prevRestrictedList)
            DomainStore.remove(appId: appId, domain: domainObj, list: .prevTrustedList)
        }
        
        if nextState == .trusted {
            //add it to trusted sites
            DomainStore.add(appId: appId, domain: domainObj, list: .trustedList)
            //remove it from restricted if it is there
            DomainStore.remove(appId: appId, domain: domainObj, list: .restrictedList)
        }
        else if nextState == .restricted {
            //add it to restricted
            DomainStore.add(appId: appId, domain: domainObj, list: .restrictedList)
            //remove from trusted if it is there
            DomainStore.remove(appId: appId, domain: domainObj, list: .trustedList)
        }
        else {
            //remove from trusted and restricted
            DomainStore.remove(appId: appId, domain: domainObj, list: .trustedList)
            DomainStore.remove(appId: appId, domain: domainObj, list: .restrictedList)
        }
    }
    
    private func changeGlobalTrackerState(to: TrackerUIState, appId: Int) {
        if to == .blocked {
            TrackerStateStore.change(appId: appId, toState: .blocked)
        }
        else if to == .empty {
            TrackerStateStore.change(appId: appId, toState: .empty)
        }
    }
    
    private func domainState2TrackerUIState(domainState: DomainState) -> TrackerUIState {
        switch domainState {
        case .trusted:
            return .trusted
        case .restricted:
            return .restricted
        case .empty:
            return .empty
        }
    }
}
