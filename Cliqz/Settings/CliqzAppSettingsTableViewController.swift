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
        
        #if GHOSTERY
        // Connect is not available in Ghostery
        #else
        // Connect
        let conenctSettings = [CliqzConnectSetting(settings: self)]
        let connectSettingsTitle = NSLocalizedString("Connect", tableName: "Cliqz", comment: "[Settings] Connect section title")
        let connectSettingsFooter = NSLocalizedString("Connect Cliqz on your computer with Cliqz on your iOS device. This will allow you to send tabs from your desktop to your mobile device. You can also directly download videos from your desktop browser to your mobile device.", tableName: "Cliqz", comment: "[Settings] Connect section footer")
        settings += [ SettingSection(title: NSAttributedString(string: connectSettingsTitle), footerTitle: NSAttributedString(string: connectSettingsFooter), children: conenctSettings)]
        #endif
        
        // Search Settings
        let searchSettings = generateSearchSettings(prefs: prefs)
        let searchSettingsTitle = NSLocalizedString("Search", tableName: "Cliqz", comment: "[Settings] Search section title")
        settings += [ SettingSection(title: NSAttributedString(string: searchSettingsTitle), children: searchSettings)]
        
        #if GHOSTERY
        // Ghostery Tab Settings
        let ghosteryTabSettings = generateCliqzTabSettings(prefs: prefs)
        let ghosteryTabTitle = NSLocalizedString("Ghostery Tab", tableName: "Cliqz", comment: "[Settings] Ghostery Tab section header")
        settings += [ SettingSection(title: NSAttributedString(string: ghosteryTabTitle), children: ghosteryTabSettings)]
        #else
        // Cliqz Tab Settings
        let cliqzTabSettings = generateCliqzTabSettings(prefs: prefs)
        let cliqzTabTitle = NSLocalizedString("Cliqz Tab", tableName: "Cliqz", comment: "[Settings] Cliqz Tab section header")
        settings += [ SettingSection(title: NSAttributedString(string: cliqzTabTitle), children: cliqzTabSettings)]
        #endif
        
        // Browsing & History Settings
        let browsingAndHistorySettings = generateBrowsingAndHistorySettings(prefs: prefs)
        let browsingAndHistoryTitle = NSLocalizedString("Browsing & History", tableName: "Cliqz", comment: "[Settings] Browsing & History section header")
        settings += [ SettingSection(title: NSAttributedString(string: browsingAndHistoryTitle), children: browsingAndHistorySettings)]
        
        // Privacy Settings
        let privacyTitle = NSLocalizedString("Privacy", tableName: "Cliqz", comment: "[Settings] Privacy section header")
        let privacySettings = generatePrivacySettings(prefs: prefs)
        settings += [ SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)]

        // Help Settings
        let helpTitle = NSLocalizedString("Help", tableName: "Cliqz", comment: "[Settings] Help section header")
        let helpSettings = generateHelpSettings(prefs: prefs)
        settings += [ SettingSection(title: NSAttributedString(string: helpTitle), children: helpSettings)]

        
        // About Settings
        let aboutTitle = NSLocalizedString("About", tableName: "Cliqz", comment: "[Settings] About section header")
        let aboutSettings = generateAboutSettings(prefs: prefs)
        settings += [ SettingSection(title: NSAttributedString(string: aboutTitle), children: aboutSettings)]

        return settings
    }

    
    // MARK:- Helper methods
    private func generateSearchSettings(prefs: Prefs) -> [Setting] {
        let regionalSetting                 = RegionalSetting(settings: self)
        let complementarySearchSetting      = ComplementarySearchSetting(settings: self)

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
        
        #if GHOSTERY
        let cliqzSearchTitle = NSLocalizedString("Cliqz Search", tableName: "Cliqz", comment: "[Settings] Cliqz Search")
        let cliqzSearchSetting = BoolSetting(prefs: prefs, prefKey: SettingsPrefs.CliqzSearchPrefKey, defaultValue: true, titleText: cliqzSearchTitle)
        #endif
        
        var searchSettings: [Setting]!
        if QuerySuggestions.querySuggestionEnabledForCurrentRegion() {
            #if GHOSTERY
            searchSettings = [regionalSetting, querySuggestionSettings, blockExplicitContentSettings, humanWebSetting, cliqzSearchSetting, complementarySearchSetting]
            #else
            searchSettings = [regionalSetting, querySuggestionSettings, blockExplicitContentSettings, humanWebSetting, complementarySearchSetting]
            #endif
        } else {
            #if GHOSTERY
            searchSettings = [regionalSetting, blockExplicitContentSettings, humanWebSetting, cliqzSearchSetting, complementarySearchSetting]
            #else
            searchSettings = [regionalSetting, blockExplicitContentSettings, humanWebSetting, complementarySearchSetting]
            #endif
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
            LimitMobileDataUsageSetting(settings: self),
            AdBlockerSetting(settings: self)
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
        
        let privacySettings = [ LoginsSetting(settings: self, delegate: settingsDelegate),
                                TouchIDPasscodeSetting(settings: self),
                                AutoForgetTabSetting(settings: self),
                                BoolSetting(prefs: prefs,
                                            prefKey: "settings.closePrivateTabs",
                                            defaultValue: false,
                                            titleText: NSLocalizedString("Close Private Tabs", tableName: "PrivateBrowsing", comment: "Setting for closing private tabs"),
                                            statusText: NSLocalizedString("When Leaving Private Browsing", tableName: "PrivateBrowsing", comment: "Will be displayed in Settings under 'Close Private Tabs'")),
                                ClearPrivateDataSetting(settings: self)]
        
        return privacySettings
    }
    
    private func generateHelpSettings(prefs: Prefs) -> [Setting] {
        
        let helpSettings = [
            SupportSetting(delegate: settingsDelegate),
            CliqzTipsAndTricksSetting(),
            ReportWebsiteSetting(),
            SendCrashReportsSetting(settings: self),
            SendUsageDataSetting(settings: self),
            MyOffrzSetting()
        ]
        
        return helpSettings
    }
    
    private func generateAboutSettings(prefs: Prefs) -> [Setting] {
        
        return [RateUsSetting(), AboutSetting()]
    }
    
    
}
