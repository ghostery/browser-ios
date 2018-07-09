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
    
    func changeState(category: String, state: TrackerUIState, section: Int, tableType: TableType) {
        
        if let domainStr = self.domainStr, tableType == .page {
            if let appIds = TrackerList.instance.trackersByCategory(domain: domainStr)[category]?.map({ (app) -> Int in return app.appId }) {
                self.changeState(appIds: appIds, state: state, tableType: tableType)
            }
        }
        else if tableType == .global {
            if let appIds = TrackerList.instance.appsByCategory[category]?.map({ (app) -> Int in return app.appId }) {
                self.changeState(appIds: appIds, state: state, tableType: tableType)
            }
        }
    }
    
    func chageSiteState(to: DomainState, completion: @escaping () -> Void) {
        
    }
    
    func changeState(appId: Int, state: TrackerUIState, section: Int?, tableType: TableType) {
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        if let domainStr = self.domainStr, tableType == .page {
            TrackerStateStore.change(appIds: [appId], domain: domainStr, toState: state)
        }
        else {
            TrackerStateStore.change(appIds: [appId], toState: state)
        }
    }
    
    func changeState(appIds: [Int], state: TrackerUIState, tableType: TableType) {
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        if let domainStr = self.domainStr, tableType == .page {
            TrackerStateStore.change(appIds: appIds, domain: domainStr, toState: state)
        }
        else {
            TrackerStateStore.change(appIds: appIds, toState: state)
        }
    }
    
    func blockAll(tableType: TableType, completion: @escaping () -> Void) {
        let timer = ParkBenchTimer()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.changeAll(state: .blocked, tableType: tableType)
            DispatchQueue.main.async {
                completion()
                timer.stop()
                debugPrint("Block All Time: \(String(describing: timer.duration))")
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
            
            var toBlock: [Int] = []
            var toEmpty: [Int] = []
            
            for tracker in trackers {
                if CategoriesHelper.categoriesBlockedByDefault.contains(tracker.category) {
                    toBlock.append(tracker.appId)
                }
                else {
                    toEmpty.append(tracker.appId)
                }
            }
            
            TrackerStateStore.change(appIds: toBlock, toState: .blocked)
            TrackerStateStore.change(appIds: toEmpty, toState: .empty)
            
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
        
        let timer = ParkBenchTimer()
        self.changeState(appIds: trackers.map{app in return app.appId}, state: state, tableType: tableType)
        timer.stop()
        debugPrint("Cahnge State Time: \(String(describing: timer.duration))")
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
