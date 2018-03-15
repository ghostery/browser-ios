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
        
        // Cliqz Tab Settings
        let cliqzTabSettings = generateCliqzTabSettings(prefs: prefs)
        let cliqzTabTitle = NSLocalizedString("Cliqz Tab", tableName: "Cliqz", comment: "[Settings] Cliqz Tab section header")
        settings += [ SettingSection(title: NSAttributedString(string: cliqzTabTitle), children: cliqzTabSettings)]
        
        // Browsing & History Settings
        let browsingAndHistorySettings = generateBrowsingAndHistorySettings(prefs: prefs)
        let browsingAndHistoryTitle = NSLocalizedString("Browsing & History", tableName: "Cliqz", comment: "[Settings] Browsing & History section header")
        settings += [ SettingSection(title: NSAttributedString(string: browsingAndHistoryTitle), children: browsingAndHistorySettings)]
        
        // Privacy Settings
        let privacyTitle = NSLocalizedString("Privacy", tableName: "Cliqz", comment: "[Settings] Privacy section header")
        let privacySettings = generatePrivacySettings(prefs: prefs)
        settings += [ SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)]

        
        settings += [
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
    
    private func generateCliqzTabSettings(prefs: Prefs) -> [Setting] {
        
        let showTopSitesTitle = NSLocalizedString("Show most visited websites", tableName: "Cliqz", comment: "[Settings] Show most visited websites")
        let showTopSitesSetting = BoolSetting(prefs: prefs, prefKey: SettingsPrefs.ShowTopSitesPrefKey, defaultValue: true, titleText: showTopSitesTitle)
        
        let showNewsTitle = NSLocalizedString("Show News", tableName: "Cliqz", comment: "[Settings] Show News")
        let showNewsSetting = BoolSetting(prefs: prefs, prefKey: SettingsPrefs.ShowNewsPrefKey, defaultValue: true, titleText: showNewsTitle)
        
        return [showTopSitesSetting, showNewsSetting]
    }
    
    private func generateBrowsingAndHistorySettings(prefs: Prefs) -> [Setting] {
        var browsingAndHistorySettings: [Setting] = [
            BoolSetting(prefs: prefs, prefKey: "blockPopups", defaultValue: true,
                        titleText: NSLocalizedString("Block Pop-up Windows", comment: "Block pop-up windows setting")),
            BoolSetting(prefs: prefs, prefKey: "saveLogins", defaultValue: true,
                        titleText: NSLocalizedString("Save Logins", comment: "Setting to enable the built-in password manager")),
            LimitMobileDataUsageSetting(settings: self)
            ]
        
        if AppConstants.MOZ_CLIPBOARD_BAR {
            browsingAndHistorySettings += [
                BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                            titleText: Strings.SettingsOfferClipboardBarTitle,
                            statusText: Strings.SettingsOfferClipboardBarStatus)
            ]
        }
        
        return browsingAndHistorySettings
    }
    
    
    private func generatePrivacySettings(prefs: Prefs) -> [Setting] {
        
        var privacySettings = [Setting]()
        privacySettings.append(LoginsSetting(settings: self, delegate: settingsDelegate))
        privacySettings.append(TouchIDPasscodeSetting(settings: self))
        privacySettings += [AutoForgetTabSetting(settings: self)]
        
        privacySettings += [
            BoolSetting(prefs: prefs,
                        prefKey: "settings.closePrivateTabs",
                        defaultValue: false,
                        titleText: NSLocalizedString("Close Private Tabs", tableName: "PrivateBrowsing", comment: "Setting for closing private tabs"),
                        statusText: NSLocalizedString("When Leaving Private Browsing", tableName: "PrivateBrowsing", comment: "Will be displayed in Settings under 'Close Private Tabs'"))
        ]
        
        privacySettings.append(ClearPrivateDataSetting(settings: self))
        
        return privacySettings
    }
}
