//
//  GhosterySQLiteFactories.swift
//  Client
//
//  Created by Mahmoud Adam on 4/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

let TableGhosteryBookmarkFolders = "zfolder"
let TableGhosteryBookmarks = "zbookmark"
let TableGhosteryTabs = "ztab"

class GhosterySQLiteFactories {
    
    class func bookmarkFolderFactory(_ row: SDRow) -> BookmarkMirrorItem {
        let id = row["Z_PK"] as! Int
        let parentId = row["ZPARENT"] as? Int
        let name = row["ZNAME"] as! String
        
        let parentGUID = parentId != nil ? String("GhosteryFolder-\(parentId!)") : BookmarkRoots.MobileFolderGUID
        
        let bookmarkFolder = BookmarkMirrorItem.folder(String("GhosteryFolder-\(id)"), dateAdded: Date.now(), modified: Date.now(), hasDupe: false, parentID: parentGUID, parentName: nil, title: name, description: name, children: [])
        return bookmarkFolder
    }
    
    class func bookmarkFactory(_ row: SDRow) -> BookmarkMirrorItem {
        let id = row["Z_PK"] as! Int
        let name = row["ZNAME"] as! String
        let url = row["ZURL"] as! String
        let folderId = row["ZFOLDER"] as? Int
        
        let parentId = folderId != nil ? String("GhosteryFolder-\(folderId!)") : BookmarkRoots.MobileFolderGUID

        let bookmark = BookmarkMirrorItem.bookmark(String("GhosteryBookmark-\(id)"), dateAdded: Date.now(), modified: Date.now(), hasDupe: false, parentID: parentId, parentName: nil, title: name, description: name, URI: url, tags: "", keyword: nil)
        return bookmark
    }
    
    
    class func tabFactory(_ row: SDRow) -> GhosteryTab {
        let id = row["Z_PK"] as! Int
        let order = row["ZORDER"] as! Int
        let url = row["ZURL"] as! String
        let tab = GhosteryTab(id, order: order, url: url)
        return tab
    }
}
