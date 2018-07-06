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
    private static let cellIdentifier = "CliqzCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.register(CliqzSiteTableViewCell.self, forCellReuseIdentifier: CliqzBookmarksPanel.cellIdentifier)
        self.refreshControl?.removeFromSuperview()
        self.refreshControl = nil
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let source = source, let bookmark = source.current[indexPath.row] else { return super.tableView(tableView, cellForRowAt: indexPath) }
        switch bookmark {
        case let item as BookmarkItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: CliqzBookmarksPanel.cellIdentifier, for: indexPath) as! CliqzSiteTableViewCell
            cell.accessoryType = .none
            let title  = item.title.isEmpty ? item.url : item.title
            cell.setLines(title, detailText: item.url)
            cell.tag = indexPath.row
            cell.imageShadowView.alpha = 0.0
            cell.imageShadowView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            LogoLoader.loadLogo(item.url, completionBlock: { (img, logoInfo, error) in
                if cell.tag == indexPath.row {
                    if let img = img {
                        cell.customImageView.image = img
                    }
                    else if let info = logoInfo {
                        let placeholder = LogoPlaceholder(logoInfo: info)
                        cell.fakeIt(placeholder)
                    }
                }
                UIView.animate(withDuration: 0.15, animations: {
                    cell.imageShadowView.alpha = 1.0
                    cell.imageShadowView.transform = CGAffineTransform.identity
                })
            })
            return cell
        default:
            // This should never happen.
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func editingStyleforRow(atIndexPath indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let source = source else {
            return .none
        }
        
        if source.current[indexPath.row] is BookmarkItem {
            // Because the deletion block is too big.
            return .delete
        }
        
        return super.editingStyleforRow(atIndexPath: indexPath)
    }
    
    override func createEmptyStateOverlayView() -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.clear
        
        let welcomeLabel = UILabel()
        overlayView.addSubview(welcomeLabel)
        welcomeLabel.text = NSLocalizedString("Favorites you save will show up here.", tableName: "Cliqz", comment: "Status label for the empty Favorites state.")
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
}
