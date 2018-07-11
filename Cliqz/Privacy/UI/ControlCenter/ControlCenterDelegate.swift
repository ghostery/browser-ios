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
        changeAll(state: .blocked, tableType: tableType, completion: completion)
    }
    
    func unblockAll(tableType: TableType, completion: @escaping () -> Void) {
        changeAll(state: .empty, tableType: tableType, completion: completion)
    }
    
    func undoAll(tableType: TableType, completion: @escaping () -> Void) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let d = self?.domainStr, tableType == .page {
                TrackerStateStore.undo(appIds: TrackerList.instance.detectedTrackersForPage(d).map {app in return app.appId}, domain: d)
            }
            else if tableType == .global {
                TrackerStateStore.undo(appIds: TrackerList.instance.appsList.map {app in return app.appId})
            }
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func restoreDefaultSettings(tableType: TableType, completion: @escaping () -> Void) {
        guard tableType == .global else { completion(); return }
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
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
    
    func changeAll(state: TrackerUIState, tableType: TableType, completion: @escaping () -> Void) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
        
            var trackers: [TrackerListApp] = []
            
            if let d = self?.domainStr, tableType == .page {
                trackers.append(contentsOf: TrackerList.instance.detectedTrackersForPage(d))
            }
            else if tableType == .global {
                trackers.append(contentsOf: TrackerList.instance.appsList)
            }

            self?.changeState(appIds: trackers.map{app in return app.appId}, state: state, tableType: tableType)
            
            DispatchQueue.main.async {
                completion()
            }
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
