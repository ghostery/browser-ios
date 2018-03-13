//
//  ToggleSubSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class ToggleSubSettingsTableViewController: SubSettingsTableViewController {
    
    private lazy var toggles: [Bool] = self.getToggles()
    private lazy var toggleTitles: [String] = self.getToggleTitles()
    private lazy var sectionFooters: [String] = self.getSectionFooters()
    
    
    override func getSectionFooter(section: Int) -> String {
        guard section < sectionFooters.count else {
            return ""
        }
        return sectionFooters[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getUITableViewCell()
        
        let control = UISwitch()
        control.onTintColor = UIConstants.ControlTintColor
        control.addTarget(self, action: #selector(switchValueChanged(_:)), for: UIControlEvents.valueChanged)
        control.isOn = toggles[indexPath.row]
        control.isEnabled = true
        control.tag = indexPath.section

        cell.textLabel?.text = toggleTitles[indexPath.row]
        cell.accessoryView = control
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        cell.textLabel?.textColor = UIColor.black
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    @objc func switchValueChanged(_ toggle: UISwitch) {
        
        self.toggles[toggle.tag] = toggle.isOn
        saveToggles(isOn: toggle.isOn, atIndex: toggle.tag)
        logTelemetryChangeSignal(isOn: toggle.isOn, atIndex: toggle.tag)
        self.tableView.reloadData()
        
    }
    
    
    // MARK:- Abstract methods
    func getToggles() -> [Bool] {
        return []
    }
    
    func getToggleTitles() -> [String] {
        return []
    }
    
    func getSectionFooters() -> [String] {
        return []
    }
    
    func saveToggles(isOn: Bool, atIndex: Int) {
        
    }
    
    func logTelemetryChangeSignal(isOn: Bool, atIndex: Int) {
        // TODO: Telemetry:
        /*
         // log telemetry signal: this is basic implementation for one toggle screen
         let state = isOn == true ? "off" : "on" // we log old value
         let valueChangedSignal = TelemetryLogEventType.Settings(getViewName(), "click", "enable", state, nil)
         TelemetryLogger.sharedInstance.logEvent(valueChangedSignal)
         */
    }
}
