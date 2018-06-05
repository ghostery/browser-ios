//
//  ControlCenterDataSource.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

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
    
    func domainString() -> String?
    func domainState() -> DomainState?
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

final class CategoriesHelper {
    static let categories = Set(arrayLiteral: "advertising", "audio_video_player", "comments", "customer_interaction", "essential", "pornvertising", "site_analytics", "social_media", "uncategorized")
    static let categoriesBlockedByDefault = Set(arrayLiteral: "pornvertising", "site_analytics", "advertising")
    static let category2NameAndColor = ["advertising": ("Advertising", UIColor(colorString: "CB55CD")),
                                 "audio_video_player": ("Audio/Video Player", UIColor(colorString: "EF671E")),
                                 "comments": ("Comments", UIColor(colorString: "43B7C5")),
                                 "customer_interaction": ("Customer Interaction", UIColor(colorString: "FDC257")),
                                 "essential": ("Essential", UIColor(colorString: "FC9734")),
                                 "pornvertising": ("Adult Content", UIColor(colorString: "ECAFC2")),
                                 "site_analytics": ("Site Analytics", UIColor(colorString: "87D7EF")),
                                 "social_media": ("Social Media", UIColor(colorString: "388EE8")),
                                 "uncategorized": ("Uncategorized", UIColor(colorString: "8459A5"))]
}

class ControlCenterDataSource: ControlCenterDSProtocol {
    
    enum CategoryState {
        case blocked
        case restricted
        case trusted
        case empty
        case other
        
        static func from(trackerState: TrackerUIState) -> CategoryState {
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
    
    var pageCategories: [String] = []
    var globalCategories: [String] = []
    
    let domainStr: String?
    var pageTrackers: Dictionary<String, [TrackerListApp]> = [:]
    var globalTrackers: Dictionary<String, [TrackerListApp]> = [:]
    
    
    //TODO: update mechanism
    init(url: URL? = nil) {
        self.domainStr = url?.normalizedHost
        DispatchQueue.global(qos: .background).async { [weak self] in
            if self != nil {
                if let domainStr = self?.domainStr {
                    self?.pageTrackers = TrackerList.instance.trackersByCategory(for: domainStr)
                    self?.pageCategories = self!.pageTrackers.reduceValues(reduce: { (list) -> Int in
                        return list.count
                    }).sortedKeysAscending(false)
                }
                self?.globalTrackers = TrackerList.instance.trackersByCategory()
                self?.globalCategories = self!.globalTrackers.reduceValues(reduce: { (list) -> Int in
                    return list.count
                }).sortedKeysAscending(false)
            }
        }
    }
    
    func domainString() -> String? {
        return self.domainStr
    }

    func countAndColorByCategory() -> Dictionary<String, (Int, UIColor)> {
        
        if UserPreferences.instance.pauseGhosteryMode == .paused {
            return ["uncategorized": (1, UIColor.gray)]
        }
        
        let countDict = TrackerList.instance.countByCategory(domain: self.domainStr)
        var dict: Dictionary<String, (Int, UIColor)> = [:]
        for key in countDict.keys {
            if let count = countDict[key], let color = CategoriesHelper.category2NameAndColor[key]?.1 {
                dict[key] = (count, color)
            }
        }
        
        return dict
    }
    
    func detectedTrackerCount() -> Int {
        return TrackerList.instance.detectedTrackerCountForPage(self.domainStr)
    }
    
    func domainState() -> DomainState? {
        guard let domain = self.domainStr else { return nil }
        return self.getOrCreateDomain(domain: domain).translatedState
    }
    
    func blockedTrackerCount() -> Int {
        guard let domain = self.domainStr else { return 0 }
        
        let domainS = domainState()
        
        if domainS == .trusted || UserPreferences.instance.pauseGhosteryMode == .paused {
            return 0
        } else if domainS == .restricted || isGlobalAntitrackingOn() {
            return detectedTrackerCount()
        }
        else {
            return TrackerList.instance.detectedTrackersForPage(domain).filter { (app) -> Bool in
                let appState = app.state(domain: self.domainStr)
                return appState == .blocked || appState == .restricted
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
        if let touple = CategoriesHelper.category2NameAndColor[category(tableType, section)] {
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
            let appState = app.state(domain: self.domainStr)
            return appState == .blocked || appState == .restricted
        }).count
    }
    
    func stateIcon(tableType: TableType, section: Int) -> UIImage? {
        
        let t = trackers(tableType: tableType, category: category(tableType, section))
        
        func trackerStates() -> Set<TrackerUIState> {
            
            var set: Set<TrackerUIState> = Set()
            
            let domain: String? = tableType == .page ? self.domainStr : nil
            
            for tracker in t {
                set.insert(tracker.state(domain: domain))
            }
            
            return set
        }
        
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
        }
        
        let set = trackerStates()
        
        let state: CategoryState
        
        if set.count == 1 {
            state = CategoryState.from(trackerState: set.first!)
        }
        else if set.count > 0{
            state = .other
        }
        else {
            state = .empty
        }
        
        return iconForCategoryState(state: state)
    }
    
    //INDIVIDUAL TRACKERS
    func title(tableType: TableType, indexPath: IndexPath) -> (String?, NSMutableAttributedString?) {
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return (nil, nil) }
        let state: TrackerUIState = t.state(domain: self.domainStr)
        
        if isGlobalAntitrackingOn() || state == .blocked || (tableType == .page && state == .restricted) {
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
        
        return iconForTrackerState(state: t.state(domain: self.domainStr))
    }
    
    func appId(tableType: TableType, indexPath: IndexPath) -> Int {
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return -1 }
        return t.appId
    }
    
    func actions(tableType: TableType, indexPath: IndexPath) -> [ActionType] {
        
        if tableType == .page {
            return [.block, .restrict, .trust]
        }
        
        guard let t = tracker(tableType: tableType, indexPath: indexPath) else { return [] }
        if t.state(domain: self.domainStr) == .blocked {
            return [.unblock]
        }
        
        return [.block]
    }
}

// MARK: - Helpers
extension ControlCenterDataSource {
    
    fileprivate func getOrCreateDomain(domain: String) -> Domain {
        //if we have done anything with this domain before we will have something in the DB
        //otherwise we need to create it
        if let domainO = DomainStore.get(domain: domain) {
            return domainO
        } else {
            return DomainStore.create(domain: domain)
        }
    }
    
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
    
    fileprivate func iconForTrackerState(state: TrackerUIState?) -> UIImage? {
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
