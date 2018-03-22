/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

/**
 * Data for identifying and constructing a HomePanel.
 */
struct HomePanelDescriptor {
    let makeViewController: (_ profile: Profile) -> UIViewController
    let imageName: String
    let accessibilityLabel: String
    let accessibilityIdentifier: String
}

class HomePanels {
    let enabledPanels = [
        HomePanelDescriptor(
            makeViewController: { profile in
				/* Cliqz: Replaced ActivityStreamPanel with Freshtab
                    return ActivityStreamPanel(profile: profile)
				*/
				return FreshtabViewController(profile: profile)
            },
            imageName: "TopSites",
            accessibilityLabel: NSLocalizedString("Top sites", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.TopSites"),

        HomePanelDescriptor(
            makeViewController: { profile in
                let bookmarks = BookmarksPanel()
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
			/* Cliqz: changed the icon
            imageName: "Bookmarks",
			*/
			imageName: "Favorite",
            accessibilityLabel: NSLocalizedString("Bookmarks", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.Bookmarks"),

        HomePanelDescriptor(
            makeViewController: { profile in
                let history = HistoryPanel()
                history.profile = profile
                let controller = UINavigationController(rootViewController: history)
                controller.setNavigationBarHidden(true, animated: false)
                controller.interactivePopGestureRecognizer?.delegate = nil
                return controller
            },
			/* Cliqz: changed the icon
            imageName: "History",
			*/
			imageName: "CliqzHistory",
            accessibilityLabel: NSLocalizedString("History", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.History"),

        HomePanelDescriptor(
            makeViewController: { profile in
			/* Cliqz: removed Reading List panel
                let controller = ReadingListPanel()
                controller.profile = profile
                return controller
			*/
				let controller = OffrzViewController(dataSource: OffrzDataSource.shared)
				return controller
            },
			/* Cliqz: changed the icon
            imageName: "ReadingList",
			*/
			imageName: "Offrz",
            accessibilityLabel: NSLocalizedString("Reading list", comment: "Panel accessibility label"),
            accessibilityIdentifier: "HomePanels.ReadingList"),
        ]
}
