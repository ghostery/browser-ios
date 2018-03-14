//
//  CliqzAppSettingsTableViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

class CliqzAppSettingsTableViewController: AppSettingsTableViewController {

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()
        let prefs = profile.prefs
        
        // Search Settings
        let searchSettings = generateSearchSettings(prefs: prefs)
        let searchSettingsTitle = NSLocalizedString("Search", tableName: "Cliqz", comment: "[Settings] Search section title")
        settings += [ SettingSection(title: NSAttributedString(string: searchSettingsTitle), children: searchSettings)]
        
        
        let privacyTitle = NSLocalizedString("Privacy", comment: "Privacy section title")
        var generalSettings: [Setting] = [
            SearchSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: "blockPopups", defaultValue: true,
                        titleText: NSLocalizedString("Block Pop-up Windows", comment: "Block pop-up windows setting")),
            BoolSetting(prefs: prefs, prefKey: "saveLogins", defaultValue: true,
                        titleText: NSLocalizedString("Save Logins", comment: "Setting to enable the built-in password manager")),
            ]
        
       
        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.
        
        if AppConstants.MOZ_CLIPBOARD_BAR {
            generalSettings += [
                BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                            titleText: Strings.SettingsOfferClipboardBarTitle,
                            statusText: Strings.SettingsOfferClipboardBarStatus)
            ]
        }
        
        // Cliqz: Automatic Forget Tab Setting
        let autoForgetTabSetting = AutoForgetTabSetting(settings: self)
        generalSettings += [autoForgetTabSetting]
        
        settings += [ SettingSection(title: NSAttributedString(string: Strings.SettingsGeneralSectionTitle), children: generalSettings)]
        
        var privacySettings = [Setting]()
        privacySettings.append(LoginsSetting(settings: self, delegate: settingsDelegate))
        privacySettings.append(TouchIDPasscodeSetting(settings: self))
        
        privacySettings.append(ClearPrivateDataSetting(settings: self))
        
        privacySettings += [
            BoolSetting(prefs: prefs,
                        prefKey: "settings.closePrivateTabs",
                        defaultValue: false,
                        titleText: NSLocalizedString("Close Private Tabs", tableName: "PrivateBrowsing", comment: "Setting for closing private tabs"),
                        statusText: NSLocalizedString("When Leaving Private Browsing", tableName: "PrivateBrowsing", comment: "Will be displayed in Settings under 'Close Private Tabs'"))
        ]
        
        settings += [
            SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings),
            SettingSection(title: NSAttributedString(string: NSLocalizedString("Support", comment: "Support section title")), children: [
                OpenSupportPageSetting(delegate: settingsDelegate),
                ]),
            SettingSection(title: NSAttributedString(string: NSLocalizedString("About", comment: "About settings section title")), children: [
                VersionSetting(settings: self)
                ])]
        
        return settings
    }

    
    // MARK:- Helper methods
    private func generateSearchSettings(prefs: Prefs) -> [Setting] {
        let querySuggestionTitle = NSLocalizedString("Search Query Suggestions", tableName: "Cliqz", comment: "[Settings] Search Query Suggestions")
        let querySuggestionSettings = BoolSetting(prefs: prefs,
                                                  prefKey: SettingsPrefs.querySuggestionPrefKey,
                                                  defaultValue: SettingsPrefs.shared.getQuerySuggestionPref(),
                                                  titleText: querySuggestionTitle)
        
        let blockExplicitContentTitle = NSLocalizedString("Block Explicit Content", tableName: "Cliqz", comment: "[Settings] Block explicit content")
        let blockExplicitContentSettings = BoolSetting(prefs: prefs,
                                                       prefKey: SettingsPrefs.BlockExplicitContentPrefKey,
                                                       defaultValue: SettingsPrefs.shared.getBlockExplicitContentPref(),
                                                       titleText: blockExplicitContentTitle)
        
        let humanWebSetting = HumanWebSetting(settings: self)
        
        
        var searchSettings: [Setting]!
        if QuerySuggestions.querySuggestionEnabledForCurrentRegion() {
            searchSettings = [querySuggestionSettings, blockExplicitContentSettings, humanWebSetting]
        } else {
            searchSettings = [blockExplicitContentSettings, humanWebSetting]
        }
        return searchSettings
    }
}
