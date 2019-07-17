//
//  BrowserDBExtensions.swift
//  Client
//
//  Created by Daniel Jilg on 17.07.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Deferred
import Shared

extension BrowserDB {
    func extendedInit() {
        // TODO: Only run this once at migration time
        migrateCliqzBookmarks()
    }

    /// Update the Database such that bookmarks from Old Cliqz Mobile show up in the new bookmarks menu.
    ///
    /// In Old Cliqz Mobile, bookmarks would only get written to the `bookmarksLocal` table. However for them
    /// to show up in this project, the bookmarks need a reference and sort order in the `bookmarksLocalStructure`
    /// table as well.
    ///
    /// In this method we try to find any bookmarks without that reference and write an entry to
    /// `bookmarksLocalStructure` for them, causing them to show up. For sorting, we use the colum
    /// `bookmarksLocal.bookmarked_date` which was introduced by Old Cliqz Mobile for this reason. We translate that
    /// sorting into `bookmarksLocalStructure.idx`, which seems intended for sorting by Firefox Mobile.
    private func migrateCliqzBookmarks() {
        // Get all unmigrated bookmarks, sorted by bookmarked_date
        let fetchUnmigratedBookmarksSQL = """
            SELECT * FROM \(TableBookmarksLocal)
            LEFT JOIN \(TableBookmarksLocalStructure) ON \(TableBookmarksLocal).guid = \(TableBookmarksLocalStructure).child
            WHERE parentid = 'mobile______'
            AND child is NULL
            ORDER BY bookmarked_date
            """
        let results = self.runQuery(fetchUnmigratedBookmarksSQL, args: nil, factory: BookmarkFactory.factory).value
        guard let oldBookmarks = results.successValue else { return }

        // Get highest idx value to add on top
        let fetchHighestIDXValueForMobileSQL = """
            SELECT idx FROM \(TableBookmarksLocalStructure)
            WHERE parent =  "mobile______"
            ORDER BY idx DESC
            LIMIT 1
            """
        guard let highestIDXResults = self.runQuery(fetchHighestIDXValueForMobileSQL, args: nil, factory: BrowserDB.idxFactory).value.successValue else { return }
        var highestIDX = 0
        for value in highestIDXResults where value != nil { highestIDX = value! }

        print(highestIDX)


        // TODO: Create entries to bookmarksLocalStructure with updated idx's
    }

    private class func idxFactory(_ row: SDRow) -> Int {
        return row["idx"] as! Int
    }
}
