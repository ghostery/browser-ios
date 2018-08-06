//
//  SubSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit


class SubSettingsTableViewController : UITableViewController {
    
    private let HeaderHeight: CGFloat = 40
    private let FooterMargin: CGFloat = 44
    private let SectionHeaderFooterIdentifier = "SectionHeaderFooterIdentifier"
    private static let DefaultCellIdentifier = "DefaultCellIdentifier"
    
    // added to calculate the duration spent on settings page
    var settingsOpenTime: Double?
    
    func getSectionFooter(section: Int) -> String {
        return ""
    }
    
    func getViewName() -> String {
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SettingsTableSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderFooterIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SubSettingsTableViewController.DefaultCellIdentifier)
        tableView.register(SettingsTableSectionHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: SectionHeaderFooterIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SubSettingsTableViewController.DefaultCellIdentifier)
        tableView.separatorColor = SettingsUX.TableViewSeparatorColor
        tableView.backgroundColor = SettingsUX.TableViewHeaderBackgroundColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.settingsOpenTime = Date.getCurrentMillis()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logHideTelemetrySignal()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView_ : UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let footer = getSectionFooter(section: section)
        if footer.isEmpty {
            return 1
        }
        return footer.height(withConstrainedWidth: tableView.bounds.width, font: UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)) + FooterMargin
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderFooterIdentifier) as! SettingsTableSectionHeaderFooterView
        header.showTopBorder = false
        return header
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderFooterIdentifier) as! SettingsTableSectionHeaderFooterView
        footer.showBottomBorder = false
        footer.showTopBorder = false
        footer.titleAlignment = .top
        footer.titleLabel.text = getSectionFooter(section: section)
        return footer
    }
    
    func getUITableViewCell(_ cellIdentifier: String = SubSettingsTableViewController.DefaultCellIdentifier, style: UITableViewCellStyle = UITableViewCellStyle.default) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: style, reuseIdentifier: cellIdentifier)
        }
        return cell
    }
    
    func logHideTelemetrySignal() {
        // TODO: Telemetry
        /*
        // Hide here mean that the user clicked back button to go to settings
        if let openTime = settingsOpenTime {
            let duration = Int(Date.getCurrentMillis() - openTime)
            let settingsBackSignal = TelemetryLogEventType.Settings(getViewName(), "click", "back", nil, duration)
            TelemetryLogger.sharedInstance.logEvent(settingsBackSignal)
            settingsOpenTime = nil
        }
        */
    }
}

