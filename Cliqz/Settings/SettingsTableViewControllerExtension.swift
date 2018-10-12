//
//  SettingsTableViewControllerExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 10/12/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension SettingsTableViewController {
    // Cliqz: used to refresh the settings table after doing actions (like restore topsites)
    func reloadSettings() {
        settings = generateSettings()
        tableView.reloadData()
    }
}
