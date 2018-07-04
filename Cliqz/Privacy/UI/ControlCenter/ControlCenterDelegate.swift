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
    
    func changeState(category: String, state: TrackerUIState, section: Int, tableType: TableType) {
        
        var trackers: [TrackerListApp] = []
        
        if let domainStr = self.domainStr, tableType == .page {
            trackers.append(contentsOf:(TrackerList.instance.trackersByCategory(domain: domainStr)[category] ?? []))
        }
        else if tableType == .global {
            trackers.append(contentsOf:(TrackerList.instance.appsByCategory[category] ?? []))
        }
        
        trackers.forEach { (app) in
            self.changeState(appId: app.appId, state: state, section: section, tableType: tableType)
        }
        
    }
    
    func chageSiteState(to: DomainState, completion: @escaping () -> Void) {
        guard let domainStr = self.domainStr else { return }
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let domainObj = self?.getOrCreateDomain(domain: domainStr) {
                DomainStore.changeState(domain: domainObj, state: to)
                
                if let nextState = self?.domainState2TrackerUIState(domainState: to) {
                    let apps = TrackerList.instance.detectedTrackersForPage(domainStr)
                    for app in apps {
                        let currentState = app.state(domain: domainStr)
                        self?.changeTrackerStateFor(domainObj: domainObj, appId: app.appId, currentState: currentState, nextState: nextState)
                        self?.changeGlobalTrackerState(to: nextState, appId: app.appId)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func changeState(appId: Int, state: TrackerUIState, section: Int?, tableType: TableType) {
        if let trackerListApp = TrackerList.instance.apps[appId] {
            
            if let s = section {
                invalidateStateImageCache(tableType: tableType, section: s)
                invalidateBlockedCountCache(tableType: tableType, section: s)
            }
            
            if let domainStr = self.domainStr, tableType == .page {
                
                let currentState = trackerListApp.state(domain: domainStr)
                let domainObj = getOrCreateDomain(domain: domainStr)
                
                DomainStore.changeState(domain: domainObj, state: .empty)
                changeTrackerStateFor(domainObj: domainObj, appId: appId, currentState: currentState, nextState: state)
            }
            
            changeGlobalTrackerState(to: state, appId: trackerListApp.appId)

        }
        else {
            debugPrint("PROBLEM -- trackerState does not exist for appId = \(appId)!")
        }
    }
    
    func blockAll(tableType: TableType, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.changeAll(state: .blocked, tableType: tableType)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func unblockAll(tableType: TableType, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.changeAll(state: .empty, tableType: tableType)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func undoAll(tableType: TableType, completion: @escaping () -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.invalidateStateImageCache()
            self?.invalidateBlockedCountCache()
            
            var trackers: [TrackerListApp] = []
            
            var domain: String? = nil
            
            if let d = self?.domainStr, tableType == .page {
                domain = d
                trackers.append(contentsOf: TrackerList.instance.detectedTrackersForPage(d))
            }
            else if tableType == .global {
                trackers.append(contentsOf: TrackerList.instance.appsList)
            }
            
            var stateSet: Set<TrackerUIState> = Set()
            
            for tracker in trackers {
                let prevState = tracker.prevState(domain: domain)
                stateSet.insert(prevState)
                self?.changeState(appId: tracker.appId, state: prevState, section: nil, tableType: tableType)
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func restoreDefaultSettings(tableType: TableType, completion: @escaping () -> Void) {
        guard tableType == .global else { completion(); return }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            self?.invalidateStateImageCache()
            self?.invalidateBlockedCountCache()
            
            let trackers = TrackerList.instance.appsList
            
            for tracker in trackers {
                if CategoriesHelper.categoriesBlockedByDefault.contains(tracker.category) {
                    self?.changeGlobalTrackerState(to: .blocked, appId: tracker.appId)
                }
                else {
                    self?.changeGlobalTrackerState(to: .empty, appId: tracker.appId)
                }
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func pauseGhostery(paused: Bool, time: Date) {
        paused ? UserPreferences.instance.pauseGhosteryDate = time : (UserPreferences.instance.pauseGhosteryDate = Date(timeIntervalSince1970: 0))
        UserPreferences.instance.writeToDisk()
    }
    
    func turnGlobalAdblocking(on: Bool) {
        on ? UserPreferences.instance.adblockingMode = .blockAll : (UserPreferences.instance.adblockingMode = .blockNone)
        UserPreferences.instance.writeToDisk()
    }
    
    private func changeAll(state: TrackerUIState, tableType: TableType) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        var trackers: [TrackerListApp] = []
        
        if let d = self.domainStr, tableType == .page {
            trackers.append(contentsOf: TrackerList.instance.detectedTrackersForPage(d))
        }
        else if tableType == .global {
            trackers.append(contentsOf: TrackerList.instance.appsList)
        }
        
        for tracker in trackers {
            self.changeState(appId: tracker.appId, state: state, section: nil, tableType: tableType)
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
