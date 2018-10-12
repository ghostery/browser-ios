//
//  SQLiteHistoryExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 10/12/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Deferred

extension SQLiteHistory {

    // Cliqz: added to get hidden topsites count
    public func getHiddenTopSitesCount() -> Int {
        var count = 0
        let countSQL = "SELECT COUNT(\(TableDomains).id) AS rowCount FROM \(TableDomains) WHERE \(TableDomains).showOnTopSites == 0"
        
        let resultSet = db.runQuery(countSQL, args: nil, factory: SQLiteHistory.countFactory).value
        if let data = resultSet.successValue {
            if let d = data[0] {
                count = d
            }
        }
        return count
    }
    
    // Cliqz: reset all hided TopSite
    public func resetHiddenTopSites() {
        self.db.run([
            "UPDATE \(TableDomains) set showOnTopSites = 1"])
    }
    
    //MARK: - Factories
    fileprivate class func countFactory(_ row: SDRow) -> Int {
        let cout = row["rowCount"] as! Int
        return cout
    }
}
