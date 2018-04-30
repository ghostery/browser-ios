//
//  BookmarkMirrorItemExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 4/30/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

extension BookmarkMirrorItem {
    public func copyWithChildrenn(_ children: [GUID]) -> BookmarkMirrorItem {
        return BookmarkMirrorItem(
            guid: self.guid,
            type: self.type,
            dateAdded: self.dateAdded,
            serverModified: self.serverModified,
            isDeleted: self.isDeleted,
            hasDupe: self.hasDupe,
            parentID: self.parentID,
            parentName: self.parentName,
            feedURI: self.feedURI,
            siteURI: self.siteURI,
            pos: self.pos,
            title: self.title,
            description: self.description,
            bookmarkURI: self.bookmarkURI,
            tags: self.tags,
            keyword: self.keyword,
            folderName: self.folderName,
            queryID: self.queryID,
            children: children,
            faviconID: self.faviconID,
            localModified: self.localModified,
            syncStatus: self.syncStatus)
    }
}
