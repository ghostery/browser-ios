//
//  AboutSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/16/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class AboutSettingsTableViewController: SubSettingsTableViewController {
    #if PAID
    private let settings = [CliqzPrivacyPolicySetting(), EulaSetting(), CliqzLicenseAndAcknowledgementsSetting()]
    #else
    private let settings = [CliqzPrivacyPolicySetting(), EulaSetting(), CliqzLicenseAndAcknowledgementsSetting(), imprintSetting()]
    #endif
    private let info = [(NSLocalizedString("Version", tableName: "Cliqz", comment: "Application Version number"), AppStatus.distVersion()),
                        (NSLocalizedString("Extension", tableName: "Cliqz", comment: "Extension version number"), AppStatus.extensionVersion()),
                        (NSLocalizedString("Device Id", tableName: "Cliqz", comment: "Device Id"), VPNCredentialsService.getDeviceId())]
    
    private var showExtraInfo = !AppStatus.isRelease()
    
    override func getViewName() -> String {
        return "about"
    }
    
    // MARK: - Table view data source
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 2
        longPressGesture.numberOfTouchesRequired = 2
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress() {
        showExtraInfo = true
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return settings.count
        }
        return showExtraInfo ? info.count : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            cell = getUITableViewCell()
            let setting = settings[indexPath.row]
            cell.textLabel?.attributedText = setting.title
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        } else {
            cell = getUITableViewCell(style: showExtraInfo ? UITableViewCellStyle.subtitle :  UITableViewCellStyle.value1)
            cell.accessoryType = .none
            cell.selectionStyle = .none
            let infoTuple = info[indexPath.row]
            cell.textLabel?.text = infoTuple.0
            cell.detailTextLabel?.text = infoTuple.1
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else {
            return
        }
        
        let setting = settings[indexPath.row]
        setting.onClick(self.navigationController)
    }
    
}

