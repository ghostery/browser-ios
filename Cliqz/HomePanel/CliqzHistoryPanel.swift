//
//  CliqzHistoryPanel.swift
//  Client
//
//  Created by Tim Palade on 5/7/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared
import Storage
import QuartzCore

struct CliqzHistoryPanelUX {
    static let iconSize: CGFloat = 44.0
    static let iconCornerRadius: CGFloat = 8.0
    static let separatorLeftInset: CGFloat = 10.0
}

private func getDate(_ dayOffset: Int) -> Date {
    let calendar = Calendar(identifier: .gregorian)
    let nowComponents = (calendar as NSCalendar).components([.year, .month, .day], from: Date())
    let today = calendar.date(from: nowComponents)!
    return (calendar as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: dayOffset, to: today, options: [])!
}

class CliqzHistoryPanel: HistoryPanel {
    
    let CliqzCellIdentifier = "CliqzCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.register(CliqzSiteTableViewCell.self, forCellReuseIdentifier: CliqzCellIdentifier)
    }
    
    override func applyTheme() {
        super.applyTheme()
        /*
        tableView.backgroundColor = UIColor.theme.tableView.rowBackground
        tableView.separatorColor = UIColor.theme.tableView.separator
        */
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
    }
	
	override func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		let newIndexPaths = indexPaths.map {IndexPath( row: $0.row, section: $0.section + 1)}
		super.tableView(tableView, prefetchRowsAt: newIndexPaths)
	}
	
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let container = UIView()
        let bubble = UIView()
        let label = UILabel()
        
        //setup
        label.text = self.tableView(tableView, titleForHeaderInSection: section + 1)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkText
        
        bubble.addSubview(label)
        container.addSubview(bubble)
        
        //styling
        bubble.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        bubble.layer.cornerRadius = 10
        
        
        //constraints
        bubble.snp.makeConstraints { (make) in
            make.center.equalTo(container)
            make.width.equalTo(label.snp.width).multipliedBy(1.5)
            make.height.equalTo(20)
        }
        
        label.snp.makeConstraints { (make) in
            make.center.equalTo(bubble)
        }
        
        return container
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count - 1
    }

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return super.tableView(tableView, numberOfRowsInSection: section + 1)
	}

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CliqzCellIdentifier, for: indexPath)
        cell.accessoryType = .none
        return configureSite(cell, for: indexPath)
    }
    
    override func configureSite(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
		if let site = siteForIndexPath(indexPath), let cell = cell as? CliqzSiteTableViewCell {
            cell.setLines(site.title, detailText: site.url)
            cell.tag = indexPath.row
            cell.imageShadowView.alpha = 0.0
            cell.imageShadowView.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
            LogoLoader.loadLogo(site.tileURL.absoluteString, completionBlock: { (img, logoInfo, error) in
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
        }
        #if PAID
        cell.textLabel?.textColor = Lumen.Browser.homePanelTextColor(lumenTheme, .Normal)
        cell.detailTextLabel?.textColor = cell.textLabel?.textColor ?? .white
        #endif
        return cell
    }
    
    override func createEmptyStateOverlayView() -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.clear
        
        let welcomeLabel = UILabel()
        overlayView.addSubview(welcomeLabel)
        welcomeLabel.text = Strings.HistoryPanelEmptyStateTitle
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = DynamicFontHelper.defaultHelper.DeviceFontLargeBold
        #if PAID
        welcomeLabel.textColor = Lumen.Browser.homePanelTextColor(lumenTheme, .Normal)
        #else
        welcomeLabel.textColor = UIColor.white
        #endif
        welcomeLabel.numberOfLines = 0
        welcomeLabel.adjustsFontSizeToFitWidth = true
        
        #if !PAID
        welcomeLabel.layer.shadowColor = UIColor.black.cgColor
        welcomeLabel.layer.shadowOpacity = 0.5
        welcomeLabel.layer.shadowRadius = 0.5
        welcomeLabel.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        #endif
        
        welcomeLabel.snp.makeConstraints { make in
            make.centerX.equalTo(overlayView)
            // Sets proper top constraint for iPhone 6 in portait and for iPad.
            make.centerY.equalTo(overlayView).offset(HomePanelUX.EmptyTabContentOffset).priority(100)
            // Sets proper top constraint for iPhone 4, 5 in portrait.
            make.top.greaterThanOrEqualTo(overlayView).offset(50)
            make.width.equalTo(170)
        }
        return overlayView
    }
}
