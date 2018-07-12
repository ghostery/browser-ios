//
//  CliqzHomePanels.swift
//  Client
//
//  Created by Tim Palade on 5/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class CliqzHomePanels {
    let enabledPanels = [
        HomePanelDescriptor(
            makeViewController: { profile in
                return FreshtabViewController(profile: profile)
        },
            imageName: "TopSites",
            accessibilityLabel: NSLocalizedString("Top sites", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.TopSites"),
        
        HomePanelDescriptor(
            makeViewController: { profile in
                let history = CliqzHistoryPanel()
                history.profile = profile
                let controller = UINavigationController(rootViewController: history)
                controller.setNavigationBarHidden(true, animated: false)
                controller.interactivePopGestureRecognizer?.delegate = nil
                return controller
        },
            imageName: "CliqzHistory",
            accessibilityLabel: NSLocalizedString("History", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.History"),
        
        HomePanelDescriptor(
            makeViewController: { profile in
                let controller = OffrzViewController(dataSource: OffrzDataSource.shared)
                return controller
        },
            
            imageName: "Offrz",
            accessibilityLabel: NSLocalizedString("Reading list", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.ReadingList"),
        
        
        HomePanelDescriptor(
            makeViewController: { profile in
                let bookmarks = CliqzBookmarksPanel()
                bookmarks.profile = profile
                let controller = UINavigationController(rootViewController: bookmarks)
                controller.setNavigationBarHidden(true, animated: false)
                // this re-enables the native swipe to pop gesture on UINavigationController for embedded, navigation bar-less UINavigationControllers
                // don't ask me why it works though, I've tried to find an answer but can't.
                // found here, along with many other places:
                // http://luugiathuy.com/2013/11/ios7-interactivepopgesturerecognizer-for-uinavigationcontroller-with-hidden-navigation-bar/
                controller.interactivePopGestureRecognizer?.delegate = nil
                return controller
        },
            imageName: "Favorite",
            accessibilityLabel: NSLocalizedString("Bookmarks", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.Bookmarks"),
        ]
}
