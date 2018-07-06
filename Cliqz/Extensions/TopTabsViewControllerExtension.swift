//
//  TopTabsViewControllerExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 7/6/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension TopTabsViewController {
    func getTobTabEmptyTitle(_ tab: Tab) -> String {
        if tab.isPrivate {
            return NSLocalizedString("Forget Tab", tableName:"Cliqz", comment: "Title of Forget Tab on iPad")
        }
        return NSLocalizedString("New Tab", tableName:"Cliqz", comment: "Title of New Tab on iPad")
    }
}
