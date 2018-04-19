//
//  BlockingCoordinator.swift
//  Client
//
//  Created by Tim Palade on 4/19/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import WebKit

final class BlockingCoordinator {
    
    static var isAdblockerOn: Bool {
        return true
    }
    
    static var isAntitrackingOn: Bool {
        return UserPreferences.instance.blockingMode != .none
    }
    
    enum BlockListType {
        case antitracking
        case adblocker
    }
    
    //order in which to load the blocklists
    static let order: [BlockListType] = [.antitracking, .adblocker]
    
    class func featureIsOn(forType: BlockListType) -> Bool {
        return forType == .antitracking ? isAntitrackingOn : isAdblockerOn
    }
    
    class func identifiersForAntitracking() -> [String] {
        if UserPreferences.instance.blockingMode == .all {
            return BlockListIdentifiers.antitrackingBlockAllIdentifiers()
        }
        else if UserPreferences.instance.blockingMode == .selected {
            return BlockListIdentifiers.antitrackingBlockSelectedIdentifiers()
        }
        
        return []
    }
    
    class func identifiersFor(type: BlockListType) -> [String] {
        return type == .antitracking ? identifiersForAntitracking() : BlockListIdentifiers.adblockingIdentifiers()
    }
    
    class func coordinatedUpdate(webView: WKWebView?) {
        guard let webView = webView else {return}
        var blockLists: [WKContentRuleList] = []
        let dispatchGroup = DispatchGroup()
        for type in order {
            if featureIsOn(forType: type) {
                //get the blocklists for that type
                dispatchGroup.enter()
                let identifiers = identifiersFor(type: type)
                BlockListManager.shared.getBlockLists(forIdentifiers: identifiers, callback: { (lists) in
                    blockLists.append(contentsOf: lists)
                    type == .antitracking ? debugPrint("Antitracking is ON") : debugPrint("Adblocking is ON")
                    dispatchGroup.leave()
                })
            }
            else {
                type == .antitracking ? debugPrint("Antitracking is OFF") : debugPrint("Adblocking is OFF")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            webView.configuration.userContentController.removeAllContentRuleLists()
            blockLists.forEach(webView.configuration.userContentController.add)
        }
    }
}
