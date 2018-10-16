//
//  RegionalSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/16/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import UIKit

class RegionalSettingsTableViewController: SubSettingsTableViewController {
    
    let regions = SettingsPrefs.SearchBackendOptions
    let telemetrySignalViewName = "search_results_from"
    static let regionsLocalizedStrings = ["region-DE" : NSLocalizedString("region-DE", tableName: "Cliqz", value: "Germany", comment: "Localized String for German region"),
                                          "region-FR" : NSLocalizedString("region-FR", tableName: "Cliqz", value: "France", comment: "Localized String for France region"),
                                          "region-US" : NSLocalizedString("region-US", tableName: "Cliqz", value: "United States", comment: "Localized String for United States region"),
                                          "region-IT" : NSLocalizedString("region-IT", tableName: "Cliqz", value: "Italy", comment: "Localized String for Italy region"),
                                          "region-ES" : NSLocalizedString("region-ES", tableName: "Cliqz", value: "Spain", comment: "Localized String for Spain region"),
                                          "region-GB" : NSLocalizedString("region-GB", tableName: "Cliqz", value: "United Kingdom", comment: "Localized String for United Kingdom region")]
    var selectedRegion: String {
        get {
            return SettingsPrefs.shared.getRegionPref()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let region = regions[indexPath.item]
        let cell = getUITableViewCell()
        
        cell.textLabel?.text = RegionalSettingsTableViewController.getLocalizedRegionName(region)
        
        if region == selectedRegion {
            // Cliqz: Mark selected the row of default search engine
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func getViewName() -> String {
        return telemetrySignalViewName
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let region = regions[indexPath.item]
        SettingsPrefs.shared.updateRegionPref(region)
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        
        // TODO: Telemetry
        /*
        let settingsBackSignal = TelemetryLogEventType.Settings(telemetrySignalViewName, "click", region, nil, nil)
        TelemetryLogger.sharedInstance.logEvent(settingsBackSignal)
        */
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
    }
    
    static func getLocalizedRegionName(_ region: String) -> String {
        let regionKey = "region-\(region)"
        if let localizedRegion = regionsLocalizedStrings[regionKey] {
            return localizedRegion
        }
        return "Undefined Region"
    }
    
}
