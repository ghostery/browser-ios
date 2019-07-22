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
import Sentry

// Cliqz
extension BrowserDB {
    static func preInit(filename: String, secretKey: String? = nil, schema: Schema, files: FileAccessor) {
        moveOldDatabase(filename: filename, schema: schema, files: files)
    }
    
    func postInit() {
        migrateCliqzBookmarks()
    }

    // MARK: - Private Implementation

    /// If Old Cliqz Mobile left a database file in the wrong location, move it to the right location
    ///
    /// Old Cliqz Mobile puts the database file in `Documents/profile.profile/` whereas the current project expects the database to live in
    /// `profile.profile/` (one level up).
    ///
    /// If a profile.profile folder exists in the `Documents` directory, we move it one level up. This ensures the migration code will find
    /// the database and do its work.
    private static func moveOldDatabase(filename: String, secretKey: String? = nil, schema: Schema, files: FileAccessor) {
        // TODO
        let newProfilePath = URL(fileURLWithPath: files.rootPath)
        let appSandboxPath = newProfilePath.deletingLastPathComponent()
        let oldProfilePath = appSandboxPath.appendingPathComponent("Documents").appendingPathComponent("profile.profile")

        let fileManager = FileManager()
        if fileManager.fileExists(atPath: oldProfilePath.path) {
            do {
                // Check if new folder exists but is empty and if yes delete it
                if fileManager.fileExists(atPath: newProfilePath.path),
                    try fileManager.contentsOfDirectory(atPath: newProfilePath.path).count == 0 {
                    try fileManager.removeItem(at: newProfilePath)
                }

                // Move old folder to new location
                try fileManager.moveItem(at: oldProfilePath, to: newProfilePath)
            } catch let e {
                Sentry.shared.send(message: "Failed to move old database to new location: \(e)", tag: .browserDB,
                                   severity: .warning, extra: nil, description: e.localizedDescription, completion: nil)
            }
        }
    }

    /// Update the Database such that bookmarks from Old Cliqz Mobile show up in the new bookmarks menu.
    ///
    /// In Old Cliqz Mobile, bookmarks would only get written to the `bookmarksLocal` table. However for them to show up in this project,
    /// the bookmarks need a reference and sort order in the `bookmarksLocalStructure` table as well.
    ///
    /// In this method we try to find any bookmarks without that reference and write an entry to `bookmarksLocalStructure` for them,
    /// causing them to show up. For sorting, we use the colum `bookmarksLocal.bookmarked_date` which was introduced by Old Cliqz Mobile
    /// for this reason. We translate that sorting into `bookmarksLocalStructure.idx`, which seems intended for sorting by Firefox Mobile.
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
        guard let oldBookmarks = results.successValue, oldBookmarks.count > 0 else { return }

        // Get highest idx value to add on top
        let fetchHighestIDXValueForMobileSQL = """
            SELECT idx FROM \(TableBookmarksLocalStructure)
            WHERE parent =  "mobile______"
            ORDER BY idx DESC
            LIMIT 1
            """
        guard let highestIDXResults = self.runQuery(fetchHighestIDXValueForMobileSQL, args: nil,
                                                    factory: BrowserDB.idxFactory).value.successValue else { return }
        var highestIDX = 0
        for value in highestIDXResults where value != nil { highestIDX = value! }

        // Create entries to bookmarksLocalStructure with updated idx's
        let insertIntoBookmarksLocalStructureSQL = """
            INSERT INTO \(TableBookmarksLocalStructure)
            ('parent', 'child', 'idx')
            VALUES (?, ?, ?);
            """
        for oldBookmark in oldBookmarks where oldBookmark != nil {
            highestIDX += 1
            _ = self.run(insertIntoBookmarksLocalStructureSQL, withArgs: ["mobile______", oldBookmark!.guid, highestIDX])
        }
    }

    private class func idxFactory(_ row: SDRow) -> Int {
        return row["idx"] as! Int
    }
}
