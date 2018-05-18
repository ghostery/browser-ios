//
//  GhosteryMigrationManager.swift
//  Client
//
//  Created by Mahmoud Adam on 4/24/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared
import Deferred

public protocol GhosteryMigrationDelegate: class {
    func openMigratedGhosteryTab(_ url: URL)
}

public class GhosteryMigrationManager {
    
    open static var shared = GhosteryMigrationManager()
    open weak var delegate: GhosteryMigrationDelegate?
    
    private static let migrationKey = "GhosteryMigrationKey"
    private static let databaseFilename = "Ghostery.sqlite"
    
    private var ghosteryDB: BrowserDB?
    private var bookmarkBuffer: BookmarkBufferStorage?
    private var bookmarkFolders: [BookmarkMirrorItem]?
    private var bookmarks: [BookmarkMirrorItem]?

    init() {
        guard UserDefaults.standard.object(forKey: GhosteryMigrationManager.migrationKey) == nil else {
            return
        }
        
        let rootPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let files = FileAccessor(rootPath: rootPath)
        let file = URL(fileURLWithPath: (try! files.getAndEnsureDirectory())).appendingPathComponent(GhosteryMigrationManager.databaseFilename).path
        if FileManager.default.fileExists(atPath: file) {
            self.ghosteryDB = BrowserDB(filename: GhosteryMigrationManager.databaseFilename, schema: BrowserSchema(), files: files)
        }
    }
    
    public func startMigration(_ bookmarkBuffer: BookmarkBufferStorage, migrationDelegate : GhosteryMigrationDelegate) {
        self.bookmarkBuffer = bookmarkBuffer
        self.delegate = migrationDelegate
        
        guard self.ghosteryDB != nil else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.migrateOpenTabs()
            self?.migrateFoldersAndBookmarks()
        }
    }
    
    private func migrateFoldersAndBookmarks() {
        let folders = self.fetchBookmarkFolders()
        if folders.value.isSuccess {
            let bookmarks = self.fetchBookmarks()
            if bookmarks.value.isSuccess {
                self.performBookmarkMigration()
                self.cleanup()
            }
        }
    }
    
    private func migrateOpenTabs() {
        let sql = "SELECT * from  \(TableGhosteryTabs) where ZURL IS NOT NULL order by ZORDER"
        ghosteryDB!.runQuery(sql, args: [], factory: GhosterySQLiteFactories.tabFactory) >>== { [weak self] tabs in
            for tab in tabs.asArray() {
                if let url = URL(string: tab.url) {
                    self?.delegate?.openMigratedGhosteryTab(url)
                }
            }
        }
    }
    
    private func fetchBookmarkFolders() -> Deferred<Maybe<Cursor<BookmarkMirrorItem>>> {
        let sql = "SELECT * from  \(TableGhosteryBookmarkFolders)"
        return ghosteryDB!.runQuery(sql, args: [], factory: GhosterySQLiteFactories.bookmarkFolderFactory) >>== { [weak self] bookmarkFolders in
            self?.bookmarkFolders = bookmarkFolders.asArray()
            return deferMaybe(bookmarkFolders)
        }
    }
    
    private func fetchBookmarks() -> Deferred<Maybe<Cursor<BookmarkMirrorItem>>> {
        let sql = "SELECT * from  \(TableGhosteryBookmarks)"
        return ghosteryDB!.runQuery(sql, args: [], factory: GhosterySQLiteFactories.bookmarkFactory) >>== { [weak self] bookmarks in
            self?.bookmarks = bookmarks.asArray()
            return deferMaybe(bookmarks)
        }
    }
    
    private func performBookmarkMigration() {
        
        var records = [BookmarkMirrorItem]()
        // Add mobile record at the start of the array
        let mobileRecord = BookmarkMirrorItem.folder(BookmarkRoots.MobileFolderGUID, dateAdded: Date.now(), modified: Date.now(), hasDupe: false, parentID: BookmarkRoots.RootGUID, parentName: "<Root>", title: "Mobile Bookmarks", description: nil, children: [])
        records.append(mobileRecord)
        
        // Append bookmark folders
        if let bookmarkFolders = self.bookmarkFolders {
            records.append(contentsOf: bookmarkFolders)
        }
        
        // Append bookmarks
        if let bookmarks = bookmarks {
            records.append(contentsOf: bookmarks)
        }
        
        // Fill in the childern attribute
        let fixedRecords = self.fixupChildern(records)
        
        // Insert the bookmarks into the database
        _ = self.bookmarkBuffer?.applyRecords(fixedRecords)
    }

    private func fixupChildern(_ bookmarks: [BookmarkMirrorItem]) -> [BookmarkMirrorItem] {
        var records = [BookmarkMirrorItem]()
        for bookmark in bookmarks {
            let childern = bookmarks.filter { bookmark.guid == $0.parentID }
            let childernGUIDs = childern.map { $0.guid }
            let fixedBookmark = bookmark.copyWithChildrenn(childernGUIDs)
            records.append(fixedBookmark)
        }
        return records
    }
    
    private func cleanup() {
        DispatchQueue.main.async { [weak self] in
            self?.ghosteryDB?.forceClose()
            UserDefaults.standard.set(true, forKey: GhosteryMigrationManager.migrationKey)
        }
    }
}
