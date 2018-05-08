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

class CliqzHistoryPanel: HistoryPanel {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.4)
        tableView.register(CliqzSiteTableViewCell.self, forCellReuseIdentifier: "CliqzCellIdentifier")
    }
    
    override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        var count = 0
        for category in self.categories where category.rows > 0 {
            count += 1
        }
        return count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let container = UIView()
        let bubble = UIView()
        let label = UILabel()
        
        //setup
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30//super.tableView(tableView, heightForHeaderInSection: trueSection(section: section))
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = String()
        guard let sl = sectionLookup[trueSection(section: section)] else {return nil}
        switch sl {
        case 0: return nil
        case 1: title = NSLocalizedString("Today", comment: "History tableview section header")
        case 2: title = NSLocalizedString("Yesterday", comment: "History tableview section header")
        case 3: title = NSLocalizedString("Last week", comment: "History tableview section header")
        case 4: title = NSLocalizedString("Last month", comment: "History tableview section header")
        default:
            assertionFailure("Invalid history section \(section)")
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.categories.isIndexValid(trueSection(section: section)) {
            return self.categories[uiSectionToCategory(trueSection(section: section))].rows
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CliqzCellIdentifier", for: indexPath) //super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .none
        return configureSite(cell, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let site = self.siteForIndexPath(indexPath), let url = URL(string: site.url) {
            let visitType = VisitType.typed    // Means History, too.
            if let homePanelDelegate = homePanelDelegate {
                homePanelDelegate.homePanel(self, didSelectURL: url, visitType: visitType)
            }
            return
        }
        print("Error: No site or no URL when selecting row.")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    override func configureSite(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        if let site = siteForIndexPath(indexPath), let cell = cell as? CliqzSiteTableViewCell {
            cell.setLines(site.title, detailText: site.url)
            cell.tag = indexPath.row
            
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
            })
        }
        return cell
    }
    
    
    override func siteForIndexPath(_ indexPath: IndexPath) -> Site? {
        let section = trueSection(section: indexPath.section)
        let offset = self.categories[sectionLookup[section]!].offset
        return data[indexPath.row + offset]
    }
    
    fileprivate func trueSection(section: Int) -> Int {
        return section + 1
    }
    
    override func updateNumberOfSyncedDevices(_ count: Int?) {
        return
    }
    
    override func updateSyncedDevicesCount() -> Success {
        return succeed()
    }
    
    @objc override func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }
        let touchPoint = longPressGestureRecognizer.location(in: tableView)
        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
        
        presentContextMenu(for: indexPath)
    }
}

class CliqzSiteTableViewCell: SiteTableViewCell {
    
    let imageShadowView = UIView()
    let customImageView = UIImageView()
    var fakeView: UIView? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: CliqzHistoryPanelUX.separatorLeftInset, bottom: 0, right: 0)
        contentView.addSubview(customImageView)
        customImageView.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        customImageView.clipsToBounds = true
        
        contentView.addSubview(imageShadowView)
        setupImageShadow()
        setUpLabels()
    }
    
    override func updateConstraints() {
        
        customImageView.snp.remakeConstraints { (make) in
            make.size.equalTo(CliqzHistoryPanelUX.iconSize)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }

        super.updateConstraints()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        else {
            self.backgroundColor = UIColor.clear
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        else {
            self.backgroundColor = UIColor.clear
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        separatorInset = UIEdgeInsets(top: 0, left: CliqzHistoryPanelUX.separatorLeftInset, bottom: 0, right: 0)
        setupImageShadow()
        setUpLabels()
        fakeView = nil
    }
    
    func fakeIt(_ view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.customImageView)
        }
        contentView.bringSubview(toFront: view)
        view.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        fakeView = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageShadow() {
        
        imageShadowView.clipsToBounds = false
        imageShadowView.backgroundColor = .white
        contentView.sendSubview(toBack: imageShadowView)
        contentView.bringSubview(toFront: customImageView)
        
        imageShadowView.snp.remakeConstraints { (make) in
            make.size.equalTo(CliqzHistoryPanelUX.iconSize)
            make.center.equalTo(customImageView.snp.center)
        }
        
        imageShadowView.layer.cornerRadius = CliqzHistoryPanelUX.iconCornerRadius
        imageShadowView.layer.shadowColor = UIColor.black.cgColor
        imageShadowView.layer.shadowOpacity = 0.5
        imageShadowView.layer.shadowRadius = 0.5
        imageShadowView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    
    private func setUpLabels() {
        
        _textLabel.textColor = .white
        _textLabel.font = UIFont.boldSystemFont(ofSize: 16)
        _textLabel.layer.shadowColor = UIColor.black.cgColor
        _textLabel.layer.shadowOpacity = 0.5
        _textLabel.layer.shadowRadius = 0.5
        _textLabel.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        
        _detailTextLabel.textColor = .white
        _detailTextLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        _detailTextLabel.layer.shadowColor = UIColor.black.cgColor
        _detailTextLabel.layer.shadowOpacity = 0.5
        _detailTextLabel.layer.shadowRadius = 0.5
        _detailTextLabel.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
}

extension Array {
    func isIndexValid(_ index: Int) -> Bool {
        return index >= 0 && index < self.count
    }
}
