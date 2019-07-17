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
        // TODO: Get all unmigrated bookmarks, sorted by bookmarked_date
        let getUnmigratedBookmarksSQL = """
            SELECT * FROM 'bookmarksLocal'
            LEFT JOIN bookmarksLocalStructure ON bookmarksLocal.guid = bookmarksLocalStructure.child
            WHERE parentid = 'mobile______'
            AND child is NULL
            ORDER BY bookmarked_date
            """

        // TODO: Get highest idx value to add on top
        let getHighestIDXValueForMobileSQL = """
            SELECT idx FROM bookmarksLocalStructure
            WHERE parent =  "mobile______"
            ORDER BY idx DESC
            LIMIT 1
            """

        // TODO: Create entries to bookmarksLocalStructure with updated idx's
    }
}
