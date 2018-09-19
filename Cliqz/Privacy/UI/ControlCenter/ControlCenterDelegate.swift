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

    func changeState(category: String, state: TrackerUIState, tableType: TableType, completion: @escaping () -> Void) {
        
        if let domainStr = self.domainStr, tableType == .page {
            if let appIds = TrackerList.instance.trackersByCategory(domain: domainStr)[category]?.map({ (app) -> Int in return app.appId }) {
                LoadingNotificationManager.shared.changeInControlCenter()
                self.changeState(appIds: appIds, state: state, tableType: tableType, completion: {
                    completion()
                })
            }
        }
        else if tableType == .global {
            if let appIds = TrackerList.instance.appsByCategory[category]?.map({ (app) -> Int in return app.appId }) {
                LoadingNotificationManager.shared.changeInControlCenter()
                self.changeState(appIds: appIds, state: state, tableType: tableType, completion: {
                    completion()
                })
            }
        }
        else {
            completion()
        }
    }
    
    func changeState(appId: Int, state: TrackerUIState, tableType: TableType, section: Int, emptyState: EmptyState = .both, completion: @escaping () -> Void) {
        
        invalidateStateImageCache(section: section)
        invalidateBlockedCountCache(section: section)
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        if let domainStr = self.domainStr, tableType == .page {
            TrackerStateStore.change(appIds: [appId], domain: domainStr, toState: state, emptyState: emptyState, completion: {
                completion()
            })
        }
        else {
            TrackerStateStore.change(appIds: [appId], toState: state, emptyState: emptyState, completion: {
                completion()
            })
        }
    }
    
    func changeState(appIds: [Int], state: TrackerUIState, tableType: TableType, completion: @escaping () -> Void) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let d = self?.domainStr, tableType == .page {
                TrackerStateStore.change(appIds: appIds, domain: d, toState: state, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else if tableType == .global {
                TrackerStateStore.change(appIds: appIds, toState: state, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        
    }
    
    func undoState(appId: Int, tableType: TableType, completion: @escaping () -> Void) {
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        if let domainStr = self.domainStr, tableType == .page {
            TrackerStateStore.undo(appIds: [appId], domain: domainStr, completion: {
                completion()
            })
        }
        else {
            TrackerStateStore.undo(appIds: [appId], completion: {
                completion()
            })
        }
    }
    
    func undoState(appIds: [Int], tableType: TableType, completion: @escaping () -> Void) {
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let domainStr = self?.domainStr, tableType == .page {
                TrackerStateStore.undo(appIds: appIds, domain: domainStr, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else if tableType == .global {
                TrackerStateStore.undo(appIds: appIds, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    completion()
                }
            }
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
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let d = self?.domainStr, tableType == .page {
                TrackerStateStore.undo(appIds: TrackerList.instance.detectedTrackersForPage(d).map {app in return app.appId}, domain: d, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else if tableType == .global {
                TrackerStateStore.undo(appIds: TrackerList.instance.appsList.map {app in return app.appId}, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    func restoreDefaultSettings(tableType: TableType, completion: @escaping () -> Void) {
        guard tableType == .global else { completion(); return }
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
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
            
            TrackerStateStore.change(appIds: toBlock, toState: .blocked, completion: {
                TrackerStateStore.change(appIds: toEmpty, toState: .empty, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            })
        }
    }
    
    func pauseGhostery(paused: Bool, time: Date) {
        paused ? UserPreferences.instance.pauseGhosteryDate = time : (UserPreferences.instance.pauseGhosteryDate = Date(timeIntervalSince1970: 0))
        UserPreferences.instance.writeToDisk()
        LoadingNotificationManager.shared.changeInControlCenter()
    }
    
    func turnGlobalAdblocking(on: Bool) {
        on ? UserPreferences.instance.adblockingMode = .blockAll : (UserPreferences.instance.adblockingMode = .blockNone)
        UserPreferences.instance.writeToDisk()
        LoadingNotificationManager.shared.changeInControlCenter()
    }
    
    func turnDomainAdblocking(on: Bool?, completion: @escaping () -> Void) {
        if let domainString = domainStr {
            
            let state: AdblockerDomainState
            
            if on == true {
                state = .on
            }
            else if on == false {
                state = .off
            }
            else {
                state = .none
            }
            
            LoadingNotificationManager.shared.changeInControlCenter()
            
            DomainStore.changeAdblockerState(toState: state, domain: domainString, completion: completion)
        }
    }
    
    func changeAll(state: TrackerUIState, tableType: TableType, completion: @escaping () -> Void) {
        
        invalidateStateImageCache()
        invalidateBlockedCountCache()
        
        LoadingNotificationManager.shared.changeInControlCenter()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let d = self?.domainStr, tableType == .page {
                TrackerStateStore.change(appIds: TrackerList.instance.detectedTrackersForPage(d).map{app in return app.appId}, domain: d, toState: state, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else if tableType == .global {
                TrackerStateStore.change(appIds: TrackerList.instance.appsList.map{app in return app.appId}, toState: state, completion: {
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            }
            else {
                DispatchQueue.main.async {
                    completion()
                }
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
