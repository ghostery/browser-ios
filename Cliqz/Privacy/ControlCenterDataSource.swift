//
//  ControlCenterDataSource.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

enum TableType {
    case page
    case global
}

enum ActionType {
    case trust
    case block
    case unblock
    case restrict
}

protocol ControlCenterDSProtocol: class {
    
    func domainString() -> String
    func domainState() -> DomainState
    func countAndColorByCategory() -> Dictionary<String, (Int, UIColor)>
    func detectedTrackerCount() -> Int
    func blockedTrackerCount() -> Int
    func isGhosteryPaused() -> Bool
    func isGlobalAntitrackingOn() -> Bool
    func isGlobalAdblockerOn() -> Bool
    func antitrackingCount() -> Int
    
    //SECTIONS
    func numberOfSections(tableType: TableType) -> Int
    func numberOfRows(tableType: TableType, section: Int) -> Int
    func title(tableType: TableType, section: Int) -> String
    func image(tableType: TableType, section: Int) -> UIImage?
    func category(_ tableType: TableType, _ section: Int) -> String
    func trackerCount(tableType: TableType, section: Int) -> Int
    func blockedTrackerCount(tableType: TableType, section: Int) -> Int
    func stateIcon(tableType: TableType, section: Int) -> UIImage?
    
    //INDIVIDUAL TRACKERS
    func title(tableType: TableType, indexPath: IndexPath) -> (String?, NSMutableAttributedString?)
    func stateIcon(tableType: TableType, indexPath: IndexPath) -> UIImage?
    func appId(tableType: TableType, indexPath: IndexPath) -> Int
    func actions(tableType: TableType, indexPath: IndexPath) -> [ActionType]
}

class ControlCenterDataSource: ControlCenterDSProtocol {
    
    enum CategoryState {
        case blocked
        case restricted
        case trusted
        case empty
        case other
        
        static func from(trackerState: TrackerStateEnum) -> CategoryState {
            switch trackerState {
            case .blocked:
                return .blocked
            case .restricted:
                return .restricted
            case .trusted:
                return .trusted
            case .empty:
                return .empty
            }
        }
    }
    
    let category2NameAndColor = ["advertising": ("Advertising", UIColor(colorString: "CB55CD")),
                                 "audio_video_player": ("Audio/Video Player", UIColor(colorString: "EF671E")),
                                 "comments": ("Comments", UIColor(colorString: "43B7C5")),
                                 "customer_interaction": ("Customer Interaction", UIColor(colorString: "FDC257")),
                                 "essential": ("Essential", UIColor(colorString: "FC9734")),
                                 "pornvertising": ("Adult Content", UIColor(colorString: "ECAFC2")),
                                 "site_analytics": ("Site Analytics", UIColor(colorString: "87D7EF")),
                                 "social_media": ("Social Media", UIColor(colorString: "388EE8")),
                                 "uncategorized": ("Uncategorized", UIColor(colorString: "8459A5"))]
    
    var pageCategories: [String] = []
    var globalCategories: [String] = []
    
    let domainStr: String
    var pageTrackers: Dictionary<String, [TrackerListApp]> = [:]
    var globalTrackers: Dictionary<String, [TrackerListApp]> = [:]
    
    
    //TODO: update mechanism
    init(url: URL) {
        self.domainStr = url.normalizedHost ?? url.absoluteString
        DispatchQueue.global(qos: .background).async {
            self.pageTrackers = TrackerList.instance.trackersByCategory(for: self.domainStr)
            self.pageCategories = self.pageTrackers.reduceValues(reduce: { (list) -> Int in
                return list.count
            }).sortedKeysAscending(false)
            self.globalTrackers = TrackerList.instance.trackersByCategory()
            self.globalCategories = self.globalTrackers.reduceValues(reduce: { (list) -> Int in
                return list.count
            }).sortedKeysAscending(false)
        }
    }
    
    func domainString() -> String {
        return domainStr
    }
    
    func domainState() -> DomainState {
        if let domainObj = DomainStore.get(domain: self.domainStr) {
            return domainObj.translatedState
        }
        return .empty //placeholder
    }

    func countAndColorByCategory() -> Dictionary<String, (Int, UIColor)> {
        
        if UserPreferences.instance.pauseGhosteryMode == .paused {
            return ["uncategorized": (1, UIColor.gray)]
        }
        
        let countDict = TrackerList.instance.countByCategory(domain: self.domainStr)
        var dict: Dictionary<String, (Int, UIColor)> = [:]
        for key in countDict.keys {
            if let count = countDict[key], let color = category2NameAndColor[key]?.1 {
                dict[key] = (count, color)
            }
        }
        
        return dict
    }
    
    func detectedTrackerCount() -> Int {
        return TrackerList.instance.detectedTrackerCountForPage(self.domainStr)
    }
    
    func blockedTrackerCount() -> Int {
        let domainS = domainState()
        
        if domainS == .trusted || UserPreferences.instance.pauseGhosteryMode == .paused {
            return 0
        } else if domainS == .restricted || isGlobalAntitrackingOn() {
            return detectedTrackerCount()
        }
        else {
            return TrackerList.instance.detectedTrackersForPage(self.domainStr).filter { (app) -> Bool in
                if let domainObj = DomainStore.get(domain: self.domainStr) {
                    return app.state.translatedState == .blocked || domainObj.restrictedTrackers.contains(app.appId) //TODO: Make this more efficient. Lookup in the list is n.
                }
                return app.state.translatedState == .blocked
                }.count
        }
    }
    
    func isGhosteryPaused() -> Bool {
        return UserPreferences.instance.pauseGhosteryMode == .paused
    }
    
    func isGlobalAntitrackingOn() -> Bool {
        return UserPreferences.instance.antitrackingMode == .blockAll
    }
    
    func isGlobalAdblockerOn() -> Bool {
        return UserPreferences.instance.adblockingMode == .blockAll
    }
    
    func antitrackingCount() -> Int {
        return self.blockedTrackerCount()
    }
    
    //SECTIONS
    func numberOfSections(tableType: TableType) -> Int {
        return source(tableType).keys.count
    }
    
    func numberOfRows(tableType: TableType, section: Int) -> Int {
        return trackers(tableType: tableType, category: category(tableType, section)).count
    }
    
    func title(tableType: TableType, section: Int) -> String {
        if let touple = category2NameAndColor[category(tableType, section)] {
            return touple.0
        }
        return ""
    }
    
    func image(tableType: TableType, section: Int) -> UIImage? {
        return UIImage(named: category(tableType, section))
    }
    
    func category(_ tableType: TableType, _ section: Int) -> String {
        let categories: [String]
        if tableType == .page {
            categories = self.pageCategories
        }
        else {
            categories = self.globalCategories
        }
        
        guard categories.isIndexValid(index: section) else { return "" }
        return categories[section]
    }
 
    func trackerCount(tableType: TableType, section: Int) -> Int {
        return self.numberOfRows(tableType: tableType, section: section)
    }
    
    func blockedTrackerCount(tableType: TableType, section: Int) -> Int {
        if isGlobalAntitrackingOn() {
            return trackerCount(tableType:tableType, section: section)
        }
        
        return trackers(tableType: tableType, category: category(tableType, section)).filter({ (app) -> Bool in
            let translatedState = app.state.translatedState
            return translatedState == .blocked || translatedState == .restricted
        }).count
    }
    
    func stateIcon(tableType: TableType, section: Int) -> UIImage? {
        
        if isGlobalAntitrackingOn() {
            return iconForCategoryState(state: .blocked)
        }
        
        if tableType == .page {
            let domainState = self.domainState()
            
            if domainState == .restricted {
                return iconForCategoryState(state: .restricted)
            }
            else if domainState == .trusted {
                return iconForCategoryState(state: .trusted)
            }
            else {
                return iconForTrackerState(state: TrackerStateEnum.empty)
            }
        }
        else {
            let t = trackers(tableType: tableType, category: category(tableType, section))
            
            var set: Set<TrackerStateEnum> = Set()
            
            for tracker in t {
                set.insert(tracker.state.translatedState)
            }
            
            let state: CategoryState
            
            if set.count > 1 {
                state = .other
            }
            else if set.count == 1 {
                state = CategoryState.from(trackerState: set.first!)
            }
            else {
                state = .empty
            }
            
            return iconForCategoryState(state: state)
        }
    }
    
    //INDIVIDUAL TRACKERS
    func title(tableType: TableType, indexPath: IndexPath) -> (String?, NSMutableAttributedString?) {
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return (nil, nil) }
        let state: TrackerStateEnum = t.state.translatedState
        
        if state == .blocked || state == .restricted || isGlobalAntitrackingOn() {
            let str = NSMutableAttributedString(string: t.name)
            str.addAttributes([NSStrikethroughStyleAttributeName : 1], range: NSMakeRange(0, t.name.count))
            return (nil, str)
        }
        
        return (t.name, nil)
    }
    
    func stateIcon(tableType: TableType, indexPath: IndexPath) -> UIImage? {
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return nil }
        
        if isGlobalAntitrackingOn() {
            return iconForTrackerState(state: .blocked)
        }
        
        if tableType == .page {
            let domainState = self.domainState()
            
            if domainState == .restricted {
                return iconForTrackerState(state: .restricted)
            }
            else if domainState == .trusted {
                return iconForTrackerState(state: .trusted)
            }
        }
        
        return iconForTrackerState(state: t.state.translatedState)
    }
    
    func appId(tableType: TableType, indexPath: IndexPath) -> Int {
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return -1 }
        return t.appId
    }
    
    func actions(tableType: TableType, indexPath: IndexPath) -> [ActionType] {
        
        if domainState() != .none {
            return []
        }
        
        if tableType == .page {
            return [.block, .restrict, .trust]
        }
        
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return [] }
        if t.state.translatedState == .blocked {
            return [.unblock]
        }
        
        return [.block]
    }
}

// MARK: - Helpers
extension ControlCenterDataSource {
    
    fileprivate func source(_ tableType: TableType) -> Dictionary<String, [TrackerListApp]> {
        if tableType == .page {
            return self.pageTrackers
        }
        
        return self.globalTrackers
    }
    
    fileprivate func trackers(tableType: TableType, category: String) -> [TrackerListApp] {
        return source(tableType)[category] ?? []
    }
    
    fileprivate func tracker(tableType: TableType, indexPath: IndexPath) -> TrackerListApp? {
        let (section, row) = sectionAndRow(indexPath: indexPath)
        let t = trackers(tableType: tableType, category: category(tableType, section))
        guard t.isIndexValid(index: row) else { return nil }
        return t[row]
    }
    
    fileprivate func sectionAndRow(indexPath: IndexPath) -> (Int, Int) {
        return (indexPath.section, indexPath.row)
    }
    
    fileprivate func iconForTrackerState(state: TrackerStateEnum?) -> UIImage? {
        if let state = state {
            switch state {
            case .empty:
                return UIImage(named: "empty")
            case .blocked:
                return UIImage(named: "blockTracker")
            case .restricted:
                return UIImage(named: "restrictTracker")
            case .trusted:
                return UIImage(named: "trustTracker")
            }
        }
        return nil
    }
    
    fileprivate func iconForCategoryState(state: CategoryState?) -> UIImage? {
        if let state = state {
            switch state {
            case .empty:
                return UIImage(named: "empty")
            case .blocked:
                return UIImage(named: "blockTracker")
            case .restricted:
                return UIImage(named: "restrictTracker")
            case .trusted:
                return UIImage(named: "trustTracker")
            case .other:
				return UIImage(named: "minus")

            }
        }
        return nil
    }
}

extension Array {
    func isIndexValid(index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
}
