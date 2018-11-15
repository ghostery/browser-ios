//
//  CliqzAppSettingsOptions.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import MessageUI
import NetworkExtension

// MARK:- cliqz settings
class CliqzConnectSetting: Setting {
    
    let profile: Profile
    
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        
        let title = NSLocalizedString("Connect", tableName: "Cliqz", comment: "[Settings] Connect")
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
    }
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = ConnectTableViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class VPNConnectSetting: Setting {
    
    let profile: Profile
    weak var settingsViewController: SettingsTableViewController?
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        self.settingsViewController = settings
        
        var title = NSLocalizedString("ConnectVPN", tableName: "Cliqz", comment: "[Settings] ConnectVPN")
        
        if NEVPNManager.shared().connection.status == .connected {
            title = NSLocalizedString("DisconnectVPN", tableName: "Cliqz", comment: "[Settings] DisconnectVPN")
        }
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
    }
    
    override var accessoryType: UITableViewCellAccessoryType { return .none }
    
    override func onClick(_ navigationController: UINavigationController?) {
        if NEVPNManager.shared().connection.status == .connected {
            self.disconnectVPN()
        }
        else {
            self.connect2VPN()
        }
    }
    
    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.settingsViewController?.reloadSettings()
        }
    }
    
    func disconnectVPN() {
        NEVPNManager.shared().connection.stopVPNTunnel()
        self.reload()
    }
    
    func connect2VPN() {
        
        //Insert credentials into Keychain
        let username = "cliqz"
        
        guard let password = Bundle.main.object(forInfoDictionaryKey: "VPNPass") as? String, !password.isEmpty else {
            return
        }
        
        let keychain = DAKeychain.shared
        keychain[username] = password
        keychain["sharedSecret"] = "foxyproxy"
        
        NEVPNManager.shared().loadFromPreferences { [unowned self](error) in
            if NEVPNManager.shared().protocolConfiguration == nil {
                let newIPSec = NEVPNProtocolIPSec()
                //setUp the protocol
                newIPSec.useExtendedAuthentication = true
                
                newIPSec.authenticationMethod = .sharedSecret
                newIPSec.sharedSecretReference = keychain.load(withKey: "sharedSecret")
                
                newIPSec.username = "cliqz"
                newIPSec.passwordReference = keychain.load(withKey: username)
                newIPSec.serverAddress = "195.181.170.100"
                newIPSec.disconnectOnSleep = false
                
                NEVPNManager.shared().protocolConfiguration = newIPSec
                NEVPNManager.shared().isEnabled = true
                NEVPNManager.shared().saveToPreferences(completionHandler: { (error) in
                    try? NEVPNManager.shared().connection.startVPNTunnel()
                    self.reload()
                })
            }
            else {
                NEVPNManager.shared().isEnabled = true;
                try? NEVPNManager.shared().connection.startVPNTunnel()
                self.reload()
            }
        }
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
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
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
        #if PAID
            let title  = NSLocalizedString("Search", tableName: "Cliqz", comment: "[Settings] Complementary Search")
        #else
            let title  = NSLocalizedString("Complementary Search", tableName: "Cliqz", comment: "[Settings] Complementary Search")
        #endif
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
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

class RestoreTopSitesSetting: Setting {
    
    let profile: Profile
    weak var settingsViewController: SettingsTableViewController?
    
    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        self.settingsViewController = settings
        let hiddenTopsitesCount = self.profile.history.getHiddenTopSitesCount()
        var attributes: [NSAttributedStringKey : Any]?
        if hiddenTopsitesCount > 0 {
            attributes = [NSAttributedStringKey.foregroundColor: UIConstants.HighlightBlue]
        } else {
            attributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        }
        
        super.init(title: NSAttributedString(string: NSLocalizedString("Restore Most Visited Websites", tableName: "Cliqz", comment: "[Settings] Restore Most Visited Websites"), attributes: attributes))
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        guard self.profile.history.getHiddenTopSitesCount() > 0 else {
            return
        }
        
        let alertController = UIAlertController(
            title: "",
            message: NSLocalizedString("All most visited websites will be shown again on the startpage.", tableName: "Cliqz", comment: "[Settings] Text of the 'Restore Most Visited Websites' alert"),
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Cliqz", comment: "Cancel button in the 'Show blocked top-sites' alert"), style: .cancel) { (action) in
                /* TODO: Telemetry
                // log telemetry signal
                let cancelSignal = TelemetryLogEventType.Settings("restore_topsites", "click", "cancel", nil, nil)
                TelemetryLogger.sharedInstance.logEvent(cancelSignal)
                */
        })
        alertController.addAction(
            UIAlertAction(title: self.title?.string, style: .destructive) { (action) in
                // reset top-sites
                self.profile.history.resetHiddenTopSites()
                
                self.settingsViewController?.reloadSettings()
                /* TODO: Telemetry
                // log telemetry signal
                let confirmSignal = TelemetryLogEventType.Settings("restore_topsites", "click", "confirm", nil, nil)
                TelemetryLogger.sharedInstance.logEvent(confirmSignal)
                */
        })
        navigationController?.present(alertController, animated: true, completion: nil)
        /* TODO: Telemetry
        // log telemetry signal
        let restoreTopsitesSignal = TelemetryLogEventType.Settings("main", "click", "restore_topsites", nil, nil)
        TelemetryLogger.sharedInstance.logEvent(restoreTopsitesSignal)
        */
    }
}

class FAQSetting: Setting {
    
    override var title: NSAttributedString? {
        return NSAttributedString(string: NSLocalizedString("FAQ", tableName: "Cliqz", comment: "[Settings] FAQ"), attributes: [NSAttributedStringKey.foregroundColor: UIConstants.HighlightBlue])
    }
    
    override var url: URL? {
        #if GHOSTERY
        return URL(string: "https://ghostery.zendesk.com/hc/en-us/categories/115000106334-iOS-Mobile-FAQ")
        #else
        return URL(string: "https://cliqz.com/support")
        #endif
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

class SupportSetting: Setting {
    
    override var title: NSAttributedString? {
        return NSAttributedString(string: NSLocalizedString("Support", tableName: "Cliqz", comment: "[Settings] Support"), attributes: [:])
    }
    
    override var url: URL? {
    #if GHOSTERY
        return URL(string: "https://ghostery.zendesk.com/hc/en-us/requests/new")
    #else
        return URL(string: "https://cliqz.com/support")
    #endif
    }
    
    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true, completion: {})
        
        if !MFMailComposeViewController.canSendMail() {
            self.delegate?.settingsOpenURLInNewTab(self.url!)
        }
        else if let nav = navigationController as? SettingsNavigationController, let vc = nav.popoverDelegate as? BrowserViewController {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = vc
            mailVC.setToRecipients(["mobile@ghostery.com"])
            mailVC.setSubject("Ghostery Mobile Browser Feedback")
            mailVC.setMessageBody("[\(UIDevice.current.modelName), \(UIDevice.current.systemVersion), \(AppStatus.distVersion()), \(AppStatus.extensionVersion())]", isHTML: false)
            
            vc.present(mailVC, animated: true, completion: nil)
        }
        
        // TODO: Telemetry
        /*
        // Cliqz: log telemetry signal
        let contactSignal = TelemetryLogEventType.Settings("main", "click", "contact", nil, nil)
        TelemetryLogger.sharedInstance.logEvent(contactSignal)
        */
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
    #if GHOSTERY
    override var url: URL? {
        return URL(string: "https://www.ghostery.com/faqs/what-is-ghostery-rewards/")
    }
    #endif
}


class RateUsSetting: Setting {
    
    init() {
        super.init(title: NSAttributedString(string: NSLocalizedString("Rate Us", tableName: "Cliqz", comment: "[Settings] Rate Us"), attributes: [NSAttributedStringKey.foregroundColor: UIConstants.HighlightBlue]))
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
        super.init(title: NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: SettingsUX.TableViewRowTextColor]))
    }
    
    override var accessoryType: UITableViewCellAccessoryType { return .disclosureIndicator }
    
    
    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = AboutSettingsTableViewController()
        viewController.title = self.title?.string
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class imprintSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Imprint", tableName: "Cliqz", comment: "[Settings -> About] Imprint")
    }
    
    override var url: URL? {
        #if GHOSTERY
        return URL(string: "https://www.ghostery.com/about-ghostery/")
        #else
        return URL(string: "https://cliqz.com/legal")
        #endif
        
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

#if GHOSTERY
class CliqzTipsAndTricksSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Get the best out of CLIQZ", tableName: "Cliqz", comment: "[Settings] Get the best out of CLIQZ")
    }
    
    override var url: URL? {
        return URL(string: "https://www.ghostery.com")
    }
}

class EulaSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("EULA", tableName: "Cliqz", comment: "[Settings -> About] EULA")
    }
    
    override var url: URL? {
        return URL(string: "https://www.ghostery.com/about-ghostery/mobile-browser-end-user-license-agreement/")
    }
}

class CliqzPrivacyPolicySetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Privacy Policy", tableName: "Cliqz", comment: "[Settings -> About] Privacy Policy")
    }
    
    override var url: URL? {
        return URL(string: "https://www.ghostery.com/about-ghostery/mobile-browser-privacy-policy/")
    }
}

#else

class CliqzTipsAndTricksSetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Get the best out of CLIQZ", tableName: "Cliqz", comment: "[Settings] Get the best out of CLIQZ")
    }
    
    override func getPageName() -> String {
        return "tips-ios"
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

class CliqzPrivacyPolicySetting: ShowCliqzPageSetting {
    
    override func getTitle() -> String {
        return NSLocalizedString("Privacy Policy", tableName: "Cliqz", comment: "[Settings -> About] Privacy Policy")
    }
    
    override func getPageName() -> String {
        return "mobile/privacy-cliqz-for-ios"
    }
}

#endif


