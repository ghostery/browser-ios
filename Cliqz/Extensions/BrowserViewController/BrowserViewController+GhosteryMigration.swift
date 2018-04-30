//
//  BrowserViewController+GhosteryMigration.swift
//  Storage
//
//  Created by Mahmoud Adam on 4/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

extension BrowserViewController : GhosteryMigrationDelegate {
    
    func openMigratedGhosteryTab(_ url: URL) {
        DispatchQueue.main.async {
            self.openURLInNewTab(url, isPrivileged: false)
        }
    }
}
