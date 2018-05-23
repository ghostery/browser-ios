//
//  CliqzAppSettingsOptions.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

// MARK:- cliqz settings
class CliqzConnectSetting: Setting {
    
    let profile: Profile
    
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        
        let title = NSLocalizedString("Connect", tableName: "Cliqz", comment: "[Settings] Connect")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: SettingsUX.TableViewRowTextColor]))
    }
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = ConnectTableViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class RegionalSetting: Setting {
    let profile: Profile
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    override var style: UITableViewCellStyle { return .value1 }
    
    override var status: NSAttributedString {
        let region = SettingsPrefs.shared.getRegionPref()
        let localizedRegionName = RegionalSettingsTableViewController.getLocalizedRegionName(region)
        return NSAttributedString(string: localizedRegionName)
    }
    
    override var accessibilityIdentifier: String? { return "Search Results for" }
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        let title = NSLocalizedString("Search Results for", tableName: "Cliqz" , comment: "[Settings] Search Results for")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: SettingsUX.TableViewRowTextColor]))
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = RegionalSettingsTableViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
        
        // TODO: Telemetry
        /*
        // log Telemerty signal
        let blcokAdsSingal = TelemetryLogEventType.Settings("main", "click", "search_results_from", nil, nil)
        TelemetryLogger.sharedInstance.logEvent(blcokAdsSingal)
        */
    }
}

class HumanWebSetting: CliqzOnOffSetting {
    
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Human Web", tableName: "Cliqz", comment: "[Settings] Human Web")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getHumanWebPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return HumanWebSettingsTableViewController()
    }
}

class ComplementarySearchSetting: Setting, SearchEnginePickerDelegate {
    let profile: Profile
    var navigationController: UINavigationController?
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    override var style: UITableViewCellStyle { return .value1 }
    
    override var status: NSAttributedString { return NSAttributedString(string: profile.searchEngines.defaultEngine.shortName) }
    
    override var accessibilityIdentifier: String? { return "Search" }
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: NSLocalizedString("Complementary Search", tableName: "Cliqz", comment: "[Settings] Complementary Search"), attributes: [NSForegroundColorAttributeName: SettingsUX.TableViewRowTextColor]))
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        let searchEnginePicker = SearchEnginePicker()
        // Order alphabetically, so that picker is always consistently ordered.
        // Every engine is a valid choice for the default engine, even the current default engine.
        let searchEngines = profile.searchEngines
        searchEnginePicker.engines = searchEngines.orderedEngines.sorted { e, f in e.shortName < f.shortName }
        searchEnginePicker.delegate = self
        searchEnginePicker.selectedSearchEngineName = searchEngines.defaultEngine.shortName
        navigationController?.pushViewController(searchEnginePicker, animated: true)
        self.navigationController = navigationController
    }
    
    func searchEnginePicker(_ searchEnginePicker: SearchEnginePicker?, didSelectSearchEngine searchEngine: OpenSearchEngine?) {
        if let engine = searchEngine {
            profile.searchEngines.defaultEngine = engine
        }
        _ = navigationController?.popViewController(animated: true)
    }
}

class AutoForgetTabSetting: CliqzOnOffSetting {
    
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Automatic Forget Tab", tableName: "Cliqz", comment: " [Settings] Automatic Forget Tab")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getAutoForgetTabPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return AutoForgetTabTableViewController()
    }
    
}


class LimitMobileDataUsageSetting: CliqzOnOffSetting {
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Limit Mobile Data Usage", tableName: "Cliqz", comment: "[Settings] Limit Mobile Data Usage")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getLimitMobileDataUsagePref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return LimitMobileDataUsageTableViewController()
    }
    
}

class AdBlockerSetting: CliqzOnOffSetting {
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Block Ads", tableName: "Cliqz", comment: "[Settings] Block Ads")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getAdBlockerPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return AdBlockerSettingsTableViewController()
    }
}


class SupportSetting: Setting {
    
    override var title: NSAttributedString? {
        return NSAttributedString(string: NSLocalizedString("FAQ & Support", tableName: "Cliqz", comment: "[Settings] FAQ & Support"),attributes: [NSForegroundColorAttributeName: UIConstants.HighlightBlue])
    }
    
    override var url: URL? {
        return URL(string: "https://cliqz.com/support")
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true, completion: {})
        self.delegate?.settingsOpenURLInNewTab(self.url!)
        
        // TODO: Telemetry
        /*
        // Cliqz: log telemetry signal
        let contactSignal = TelemetryLogEventType.Settings("main", "click", "contact", nil, nil)
        TelemetryLogger.sharedInstance.logEvent(contactSignal)
        */
    }
    
}

class CliqzTipsAndTricksSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Get the best out of CLIQZ", tableName: "Cliqz", comment: "[Settings] Get the best out of CLIQZ")
    }
    
    override func getPageName() -> String {
        return "tips-ios"
    }
}

class ReportWebsiteSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Report Website", tableName: "Cliqz", comment: "[Settings] Report Website")
    }
    
    override func getPageName() -> String {
        return "report-url"
    }
}

class SendCrashReportsSetting: CliqzOnOffSetting {
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Send Crash Reports", tableName: "Cliqz", comment: "[Settings] Send Crash Reports")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getSendCrashReportsPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return SendCrashReportsTableViewController()
    }
}

class SendUsageDataSetting: CliqzOnOffSetting {
    init(settings: SettingsTableViewController) {
        let title  = NSLocalizedString("Send usage data", tableName: "Cliqz", comment: "[Settings] Send usage data")
        super.init(settings: settings, title: title)
    }
    
    override func isOn() -> Bool {
        return SettingsPrefs.shared.getSendUsageDataPref()
    }
    
    override func getSubSettingViewController() -> SubSettingsTableViewController {
        return SendUsageDataTableViewController()
    }
}

class MyOffrzSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("About MyOffrz", tableName: "Cliqz", comment: "[Settings] About MyOffrz")
    }
    
    override func getPageName() -> String {
        return "myoffrz"
    }
}


class RateUsSetting: Setting {
    
    init() {
        super.init(title: NSAttributedString(string: NSLocalizedString("Rate Us", tableName: "Cliqz", comment: "[Settings] Rate Us"), attributes: [NSForegroundColorAttributeName: UIConstants.HighlightBlue]))
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        var urlString: String!
        if #available(iOS 11.0, *) {
            urlString = "itms-apps://itunes.apple.com/app/id\(AppStatus.AppId)"
        } else {
            urlString = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(AppStatus.AppId)&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [String : Any](), completionHandler: nil)
        }
    }
}


class AboutSetting: Setting {
    
    override var style: UITableViewCellStyle { return .value1 }
    
    override var status: NSAttributedString { return NSAttributedString(string: "Version \(AppStatus.distVersion())") }
    
    init() {
        let title = NSLocalizedString("About", tableName: "Cliqz", comment: "[Settings] About")
        super.init(title: NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: SettingsUX.TableViewRowTextColor]))
    }
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = AboutSettingsTableViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class EulaSetting: LocalResourceSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("EULA", tableName: "Cliqz", comment: "[Settings -> About] EULA")
    }
    
    override func getResource() -> (String, String) {
        return ("eula", "about")
    }
}

class CliqzLicenseAndAcknowledgementsSetting: LocalResourceSetting {
    override func getTitle() -> String {
        return NSLocalizedString("Licenses", tableName: "Cliqz", comment: "[Settings -> About] Licenses")
    }
    
    override func getResource() -> (String, String) {
        return ("license", "about")
    }
}

class CliqzPrivacyPolicySetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Privacy Policy", tableName: "Cliqz", comment: "[Settings -> About] Privacy Policy")
    }
    
    override func getPageName() -> String {
        return "mobile/privacy-cliqz-for-ios"
    }
}
