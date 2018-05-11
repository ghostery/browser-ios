//
//  BookmarksDataSource.swift
//  Client
//
//  Created by Mahmoud Adam on 5/11/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage

class BookmarksDataSource {
    private var bookmarks: [BookmarkNode]
    
    init(_ model: BookmarksModel) {
        bookmarks = [BookmarkNode]()
        importBookmarksFromFolder(model.current)
    }
    
    func getBookmarkAtIndex(_ index: Int) -> BookmarkNode? {
        guard index < bookmarks.count else { return nil }
        
        return bookmarks[index]
    }
    
    func count() -> Int {
        return bookmarks.count
    }
    
    func removeBookmark(_ bookmark: BookmarkNode){
        self.bookmarks = bookmarks.filter { $0.guid != bookmark.guid }
    }
    
    private func importBookmarksFromFolder(_ folder: BookmarkFolder) {
        for index in 0..<folder.count {
            let bookmark = folder[index]
            switch bookmark {
            case let bookmark as BookmarkItem:
                bookmarks.append(bookmark)
            default:
                continue
            }
        }
    }
}
