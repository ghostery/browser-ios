//
//  CliqzBookmarksPanel.swift
//  Client
//
//  Created by Mahmoud Adam on 5/11/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Storage
import Shared

class CliqzBookmarksPanel: BookmarksPanel {
    var bookmarksDataSource: BookmarksDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
    }
    
    fileprivate func getCurrentBookmark(_ index: Int) -> BookmarkNode? {
        guard let bookmarksDataSource = self.bookmarksDataSource else {
            return nil
        }
        return bookmarksDataSource.getBookmarkAtIndex(index)
    }
    
    override func loadData() {
        // If we've not already set a source for this panel, fetch a new model from
        // the root; otherwise, just use the existing source to select a folder.
        guard let source = self.source else {
            // Get all the bookmarks split by folders
            if let bookmarkFolder = bookmarkFolder {
                profile.bookmarks.modelFactory >>== { $0.modelForFolder(bookmarkFolder).upon(self.onModelFetched) }
            } else {
                profile.bookmarks.modelFactory >>== { $0.flatModelForRoot().upon(self.onModelFetched) }
            }
            return
        }
        
        if let bookmarkFolder = bookmarkFolder {
            source.selectFolder(bookmarkFolder).upon(onModelFetched)
        } else {
            source.selectFolder(BookmarkRoots.MobileFolderGUID).upon(onModelFetched)
        }
    }
    
    override func onNewModel(_ model: BookmarksModel) {
        if Thread.current.isMainThread {
            self.source = model
            self.bookmarksDataSource = BookmarksDataSource(model)
            self.tableView.reloadData()
            return
        }
        
        DispatchQueue.main.async {
            self.source = model
            self.bookmarksDataSource = BookmarksDataSource(model)
            self.tableView.reloadData()
            self.updateEmptyPanelState()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarksDataSource?.count() ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let bookmark = getCurrentBookmark(indexPath.row) else { return super.tableView(tableView, cellForRowAt: indexPath) }
        switch bookmark {
        case let item as BookmarkItem:
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if item.title.isEmpty {
                cell.textLabel?.text = item.url
            } else {
                cell.textLabel?.text = item.title
            }
            cell.textLabel?.textColor = .white
            cell.textLabel?.applyShadow()
            
            if let url = bookmark.favicon?.url.asURL, url.scheme == "asset" {
                cell.imageView?.image = UIImage(named: url.host!)
            } else {
                cell.imageView?.layer.borderColor = BookmarksPanelUX.IconBorderColor.cgColor
                cell.imageView?.layer.borderWidth = BookmarksPanelUX.IconBorderWidth
                let bookmarkURL = URL(string: item.url)
                cell.imageView?.setIcon(bookmark.favicon, forURL: bookmarkURL, completed: { (color, url) in
                    if bookmarkURL == url {
                        cell.imageView?.image = cell.imageView?.image?.createScaled(CGSize(width: BookmarksPanelUX.IconSize, height: BookmarksPanelUX.IconSize))
                        cell.imageView?.backgroundColor = color
                        cell.imageView?.contentMode = .center
                    }
                })
            }
            return cell
        default:
            // This should never happen.
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    
    override func deleteBookmark(indexPath: IndexPath, source: BookmarksModel) {
        guard let bookmark = getCurrentBookmark(indexPath.row) else {
            return
        }
        
        assert(!(bookmark is BookmarkFolder))
        if bookmark is BookmarkFolder {
            // TODO: check whether the folder is empty (excluding separators). If it isn't
            // then we must ask the user to confirm. Bug 1232810.
            return
        }
        
        // Block to do this -- this is UI code.
        guard let factory = source.modelFactory.value.successValue else {
            self.onModelFailure(DatabaseError(description: "Unable to get factory."))
            return
        }
        
        let specificFactory = factory.factoryForIndex(indexPath.row, inFolder: source.current)
        if let err = specificFactory.removeByGUID(bookmark.guid).value.failureValue {
            self.onModelFailure(err)
            return
        }
        
        self.tableView.beginUpdates()
        self.bookmarksDataSource?.removeBookmark(bookmark)
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.tableView.endUpdates()
        self.updateEmptyPanelState()
    }
    
    override func createEmptyStateOverlayView() -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.clear
        
        let welcomeLabel = UILabel()
        overlayView.addSubview(welcomeLabel)
        welcomeLabel.text = emptyBookmarksText
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = DynamicFontHelper.defaultHelper.DeviceFontLargeBold
        welcomeLabel.textColor = .white
        welcomeLabel.numberOfLines = 0
        welcomeLabel.adjustsFontSizeToFitWidth = true
        welcomeLabel.applyShadow()
        
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(overlayView)
            // Sets proper top constraint for iPhone 6 in portait and for iPad.
            make.centerY.equalTo(overlayView).offset(BookmarksPanelUX.EmptyTabContentOffset).priority(100)
            // Sets proper top constraint for iPhone 4, 5 in portrait.
            make.top.greaterThanOrEqualTo(overlayView).offset(150)
            make.width.equalTo(BookmarksPanelUX.WelcomeScreenItemWidth)
        }
        
        return overlayView
    }
    
    override func updateEmptyPanelState() {
        if self.bookmarksDataSource?.count() == 0 && source?.current.guid == BookmarkRoots.MobileFolderGUID {
            if self.emptyStateOverlayView.superview == nil {
                self.view.addSubview(self.emptyStateOverlayView)
                self.view.bringSubview(toFront: self.emptyStateOverlayView)
                self.emptyStateOverlayView.snp.makeConstraints { make -> Void in
                    make.edges.equalTo(self.tableView)
                }
            }
        } else {
            self.emptyStateOverlayView.removeFromSuperview()
        }
    }
    
}
