//
//  BookmarksModelExtensions.swift
//  Storage
//
//  Created by Mahmoud Adam on 5/9/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Deferred
import Shared

extension SQLiteBookmarksModelFactory {
    public func flatModelForRoot() -> Deferred<Maybe<BookmarksModel>> {
        return self.modelForRoot()
    }
}

extension UnsyncedBookmarksFallbackModelFactory {
    public func flatModelForRoot() -> Deferred<Maybe<BookmarksModel>> {
        // Return a virtual model containing "Desktop bookmarks" prepended to the local mobile bookmarks.
        return self.localFactory.folderForGUID(BookmarkRoots.MobileFolderGUID, title: BookmarksFolderTitleMobile)
            >>== {
                localMobileFolder in
                
                self.bufferFactory.allBufferBookmarks(BookmarkRoots.MobileFolderGUID, title: BookmarksFolderTitleMobile) >>== {
                    bufferMobileFolder in
                    
                    let bufferAndLocalMobile = ConcatenatedBookmarkFolder(main: bufferMobileFolder, append: localMobileFolder)
                    return deferMaybe(BookmarksModel(modelFactory: self, root: bufferAndLocalMobile))
                }
        }
    }

}

extension MockMemoryBookmarksStore {
    public func flatModelForRoot() -> Deferred<Maybe<BookmarksModel>> {
        return self.modelForRoot()
    }
}


extension SQLiteBookmarksModelFactory {
    func allBufferBookmarks(_ parentGUID: GUID, title: String) -> Deferred<Maybe<BookmarkFolder>> {
        return self.getAllChildren()
            >>== { cursor in
                
                if cursor.status == .failure {
                    return deferMaybe(DatabaseError(description: "Couldn't get children: \(cursor.statusMessage)."))
                }
                
                return deferMaybe(SQLiteBookmarkFolder(guid: parentGUID, title: title, children: cursor))
        }
    }
    
    fileprivate func getAllChildren() -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        return self.bookmarks.getAllBufferChildren()
    }
}

extension SQLiteBookmarks {
    /**
     * Return the children of the provided parent.
     * Rows are ordered by positional index.
     * This method is aware of is_overridden and deletion, using local override structure by preference.
     * Note that a folder can be empty locally; we thus use the flag rather than looking at the structure itself.
     */
    func getAllBufferChildren(includeIcon: Bool = true, factory: @escaping (SDRow) -> BookmarkNode = BookmarkFactory.factory) -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        
        let valueView = Direction.buffer.valueView
        let structureView = Direction.buffer.structureView
        
        let structure = "SELECT parent, child AS guid, idx FROM \(structureView)"
        
        let values =
            "SELECT -1 AS id, guid, type, date_added, is_deleted, parentid, parentName, feedUri, pos, title, bmkUri, siteUri, folderName, faviconID, (0) AS isEditable " +
        "FROM \(valueView) where bmkUri is not null"
        
        let fleshed =
            "SELECT vals.id AS id, vals.guid AS guid, vals.type AS type, vals.date_added AS date_added, vals.is_deleted AS is_deleted, " +
                "       vals.parentid AS parentid, vals.parentName AS parentName, vals.feedUri AS feedUri, " +
                "       vals.siteUri AS siteUri," +
                "       vals.pos AS pos, vals.title AS title, vals.bmkUri AS bmkUri, vals.folderName AS folderName, " +
                "       vals.faviconID AS faviconID, " +
                "       vals.isEditable AS isEditable, " +
                "       structure.idx AS idx, " +
                "       structure.parent AS _parent " +
                "FROM (\(structure)) AS structure JOIN (\(values)) AS vals " +
                "ON vals.guid = structure.guid"
        
        let withIcon =
            "SELECT bookmarks.id AS id, bookmarks.guid AS guid, bookmarks.type AS type, " +
                "       bookmarks.date_added AS date_added, " +
                "       bookmarks.is_deleted AS is_deleted, " +
                "       bookmarks.parentid AS parentid, bookmarks.parentName AS parentName, " +
                "       bookmarks.feedUri AS feedUri, bookmarks.siteUri AS siteUri, " +
                "       bookmarks.pos AS pos, title AS title, " +
                "       bookmarks.bmkUri AS bmkUri, bookmarks.folderName AS folderName, " +
                "       bookmarks.idx AS idx, bookmarks._parent AS _parent, " +
                "       bookmarks.isEditable AS isEditable, " +
                "       favicons.url AS iconURL, favicons.date AS iconDate, favicons.type AS iconType " +
                "FROM (\(fleshed)) AS bookmarks " +
        "LEFT OUTER JOIN favicons ON bookmarks.faviconID = favicons.id"
        
        let sql = (includeIcon ? withIcon : fleshed) + " ORDER BY idx ASC"
        return self.db.runQuery(sql, args: nil, factory: factory)
    }
}
