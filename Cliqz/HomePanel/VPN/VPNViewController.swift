//
//  VPNViewController.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//
#if PAID

import UIKit
import NetworkExtension
import BondAPI

struct VPNUX {
    static let bgColor = UIColor(red:0.08, green:0.10, blue:0.11, alpha:1.00)
    static let cliqzBlue = UIColor(red: 7/255, green: 230/255, blue: 254/255, alpha: 1.0)
    static let secondaryBlue = UIColor(red:0.00, green:0.61, blue:0.92, alpha:1.00)
}

class VPN {
    
    static let shared = VPN()
    
    let shouldTryToReconnectKey = "VPNShouldTryToReconnectKey"
    var shouldTryToReconnect: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: shouldTryToReconnectKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let value = UserDefaults.standard.value(forKey: shouldTryToReconnectKey) as? Bool {
                return value
            }
            
            return false //default
        }
    }
    
    //do a last status, and try to reconnect if the last status is connected.
    let lastStatusKey = "VPNLastStatusKey"
    var lastStatus: NEVPNStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: lastStatusKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let statusRaw = UserDefaults.standard.value(forKey: lastStatusKey) as? Int {
                if let status = NEVPNStatus(rawValue: statusRaw) {
                    return status
                }
            }
            
            return .disconnected //default
        }
    }
    
    let connectDateKey = "VPNConnectDateKey"
    var connectDate: Date? {
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: connectDateKey)
                UserDefaults.standard.synchronize()
            }
            else {
                UserDefaults.standard.set(newValue, forKey: connectDateKey)
                UserDefaults.standard.synchronize()
            }
        }
        get {
            if let cDate = UserDefaults.standard.value(forKey: connectDateKey) as? Date {
                return cDate
            }
            
            return nil //default
        }
    }
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
    }
    
    func checkConnection() {
        /* [IP-193] Remove Authentication
        guard AuthenticationService.shared.hasValidSubscription() == true else {
            VPN.disconnectVPN()
            NEVPNManager.shared().removeFromPreferences { (error) in
//                if let e = error {
//                    //there was an error taking this out of the preferences.
//                }
            }
            return
        }
        
        */
        if (lastStatus == .connected && status != .connected) {
            VPN.connect2VPN()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var status: NEVPNStatus {
        return NEVPNManager.shared().connection.status;
    }
    
    
    //TODO: Tries to reconnect without end. Maybe this is not a good idea.
    @objc func VPNStatusDidChange(notification: Notification) {
        //keep button up to date.
        lastStatus = status
        
        if status == .connected {
            VPN.shared.shouldTryToReconnect = true
        }
        
        if (status == .disconnected && shouldTryToReconnect) {
            VPN.connect2VPN()
        }
    }
    
    static func disconnectVPN() {
        VPN.shared.shouldTryToReconnect = false
        NEVPNManager.shared().connection.stopVPNTunnel()
    }
    
    static func connect2VPN() {
        
        let country = VPNEndPointManager.shared.selectedCountry
        guard let creds = VPNEndPointManager.shared.getCredentials(country: country) else { return }

        NEVPNManager.shared().loadFromPreferences { (error) in
            if NEVPNManager.shared().protocolConfiguration == nil || NEVPNManager.shared().protocolConfiguration?.serverAddress != country.endpoint {
                let newIPSec = NEVPNProtocolIPSec()
                //setUp the protocol
                newIPSec.useExtendedAuthentication = true
                
                newIPSec.authenticationMethod = .sharedSecret
                newIPSec.sharedSecretReference = creds.sharedSecret
                
                newIPSec.username = creds.username
                newIPSec.passwordReference = creds.password
                newIPSec.serverAddress = country.endpoint;
                newIPSec.disconnectOnSleep = false
                
                //Need to figure out how to do this properly. If we do it like this it will say that the configuration is invalid.
//                let alwaysConnected = NEOnDemandRule()
//                alwaysConnected.interfaceTypeMatch = .any
//                NEVPNManager.shared().onDemandRules = [alwaysConnected]
                
                NEVPNManager.shared().protocolConfiguration = newIPSec
                NEVPNManager.shared().isOnDemandEnabled = true
                NEVPNManager.shared().isEnabled = true

                NEVPNManager.shared().saveToPreferences(completionHandler: { (error) in
                    do {
                        try NEVPNManager.shared().connection.startVPNTunnel()
                    }
                    catch {
                        VPN.shared.shouldTryToReconnect = false
                    }
                })
            }
            else {
                NEVPNManager.shared().isEnabled = true;
                do {
                    try NEVPNManager.shared().connection.startVPNTunnel()
                }
                catch {
                    VPN.shared.shouldTryToReconnect = false
                }
            }
        }
    }
}

class VPNEndPointManager {
    //manages the endpoints and credentials for each country
    
    struct Credentials {
        let username: String
        let password: Data
        let sharedSecret: Data
    }
    
    struct VPNCountry: Codable, Equatable {
        let id: String //id from the server
        let name: String //display name
        let endpoint: String //endpoint address
        
        static func != (lhs: VPNCountry, rhs: VPNCountry) -> Bool {
            return lhs.id != rhs.id
        }
        
        var hashPrefix: String {
            return "\(self.id)|\(self.endpoint)"
        }
        
        var usernameHash: String {
            return "\(self.hashPrefix)|username"
        }
        
        var passwordHash: String {
            return "\(self.hashPrefix)|password"
        }
        
        var sharedSecretHash: String {
            return "\(self.hashPrefix)|sharedSecret"
        }
    }
    
    static let defaultCountry = VPNCountry(id: "de", name: NSLocalizedString("Germany", tableName: "Lumen", comment: "VPN country name for Germany"), endpoint: "195.181.170.100")
    
    //list of possible countries. Each country has its own credentials and endpoints
    var countries: [VPNCountry] = [
        VPNCountry(id: "us", name: NSLocalizedString("USA", tableName: "Lumen", comment: "VPN country name for USA"), endpoint: "195.181.168.14"),
        defaultCountry
    ]
    
    let selectedCountryKey = "VPNSelectedCountry"
    
    var selectedCountry: VPNCountry {
        set {
            UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey: selectedCountryKey)
            UserDefaults.standard.synchronize()
        }
        get {
            
            if let data = UserDefaults.standard.value(forKey: selectedCountryKey) as? Data, let country = try? PropertyListDecoder().decode(VPNCountry.self, from: data) {
                return country
            }
            
            return VPNEndPointManager.defaultCountry //default
        }
    }
    
    static let shared = VPNEndPointManager()
    
    init() {
        //get credential for each country
        getVPNCredentialsFromServer()
    }
    
    private func getVPNCredentialsFromServer() {
		VPNCredentialsService.getVPNCredentials { [weak self] (credentials) in
			for cred in credentials {
				if let country = self?.country(id: cred.country) {
					self?.setCreds(country: country, username: cred.username, password: cred.password, sharedSecret: cred.secret)
				}
			}
		}
		/*
        let userCred = AuthenticationService.shared.generateNewCredentials("vpn@lumen.com")
        BondAPIManager.shared.currentBondHandler().getIPSecCreds(withRequest: userCred) { [weak self] (response, error) in
            //TODO: write the credentials into the keychain
            if let config = response?.config as? [String: IPSecConfig] {
                for (key, value) in config {
                    if let country = self?.country(id: key) {
                        self?.setCreds(country: country, username: value.username, password: value.password, sharedSecret: value.secret)
                    }
                }
            }
        }
		*/
    }
    
    func country(id: String) -> VPNCountry? {
        return countries.filter{$0.id == id}.first
    }
    
    func getCredentials(country: VPNCountry) -> Credentials? {
        let keychain = DAKeychain.shared
        if let username = keychain[country.usernameHash],
            let pass = keychain.load(withKey: country.passwordHash),
            let sharedS = keychain.load(withKey: country.sharedSecretHash)
        {
            return Credentials(username: username, password: pass, sharedSecret: sharedS)
        }
        //initiate a call to get the credentials?
        getVPNCredentialsFromServer()
        return nil
    }
    
    private func setCreds(country: VPNCountry, username: String, password: String, sharedSecret: String) {
        let keychain = DAKeychain.shared
        keychain[country.usernameHash] = username
        keychain[country.passwordHash] = password
        keychain[country.sharedSecretHash] = sharedSecret
    }
}

class VPNViewController: UIViewController {
    
    //used to reconnect when changing countries
    var shouldVPNReconnect = false
    
    let tableView = UITableView()
    let mapView = UIImageView()
    
    let connectButton = VPNButton()
    let infoLabel = UILabel()
    
    let countryButtonHeight: CGFloat = 50.0
    
    var upgradeView: UpgradeView?
    
    var VPNStatus: NEVPNStatus {
        return VPN.shared.status;
    }
    
    var timer: Timer? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        setupComponents()
        setConstraints()
        setStyling()
        
        updateMapView()
        updateConnectButton()
        updateInfoLabel()
    }
    
    private func setupComponents() {
        tableView.register(CustomVPNCell.self, forCellReuseIdentifier: "VPNCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        connectButton.setTitleColor(.blue, for: .normal)
        connectButton.tintColor = .blue
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(mapView)
        view.addSubview(infoLabel)
        view.addSubview(connectButton)
        #if PAID
        if let trialRemainingDays = SubscriptionController.shared.getCurrentSubscription().trialRemainingDays(), trialRemainingDays < 8 {
            self.upgradeView = UpgradeView()
            self.upgradeView?.delegate = self
            view.addSubview(upgradeView!)
        }
        #endif
    }
    
    private func setConstraints() {
        if let upgradeView = self.upgradeView {
            upgradeView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(UpgradeViewUX.height)
            }
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(upgradeView.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(countryButtonHeight)
            }
        } else {
            tableView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(countryButtonHeight)
            }
        }
        
        mapView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(tableView.snp.bottom).offset(20)
        }
        
        connectButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(infoLabel.snp.top).offset(-16)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-26)
            make.width.equalToSuperview().dividedBy(1.25)
            make.centerX.equalToSuperview()
            //I should not set the height. Quick fix.
            make.height.equalTo(40)
        }
    }
    
    private func setStyling() {
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.textColor = Lumen.VPN.infoLabelTextColor(lumenTheme, .Normal)
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        mapView.contentMode = .scaleAspectFill
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.alpha = 1.0
        updateMapView()
        updateConnectButton()
        updateInfoLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateConnectButton() {
        
        if VPNStatus == .connected {
            self.connectButton.set(state: .Disconnect)
            //start timer
            timer = Timer.scheduledTimer(timeInterval: 0.95, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            timer?.fire()
            if VPN.shared.connectDate == nil {
                VPN.shared.connectDate = Date()
            }
        }
        else if VPNStatus == .disconnected {
            if self.connectButton.currentState == .Connecting || self.connectButton.currentState == .Connect {
                self.connectButton.set(state: .Retry)
            }
            self.connectButton.set(state: .Connect)
            timer?.invalidate()
            timer = nil
            VPN.shared.connectDate = nil
        }
        else if VPNStatus == .disconnecting {
            self.connectButton.set(state: .Disconnecting)
        }
        else if VPNStatus == .connecting {
            self.connectButton.set(state: .Connecting)
        }
        else {
            self.connectButton.set(state: .Connect)
        }
    }
    
    func updateMapView() {
        
        if VPNStatus == .connected {
            //active image
            mapView.image = Lumen.VPN.mapImageActive(lumenTheme, .Normal)
        }
        else {
            //inactive image
            mapView.image = Lumen.VPN.mapImageInactive(lumenTheme, .Normal)
        }
    }
    
    func updateInfoLabel() {
        
        let connectedText = NSLocalizedString("You are safely connected to the Internet.", tableName: "Lumen", comment: "VPN connected text")
        let retryText = NSLocalizedString("You are safely connected to the Internet.", tableName: "Lumen", comment: "VPN retry text")
        let defaultText = NSLocalizedString("Tap 'connect' to browse the Internet with VPN protection.", tableName: "Lumen", comment: "VPN default text")
        
        if VPNStatus == .connected {
            self.infoLabel.text = connectedText
        }
        else if VPNStatus == .disconnected && (self.connectButton.currentState == .Connecting || self.connectButton.currentState == .Connect) {
                self.infoLabel.text = retryText
        }
        else {
            self.infoLabel.text = defaultText
        }
    }
    
    @objc func VPNStatusDidChange(notification: Notification) {
        //keep button up to date.
        updateInfoLabel()
        updateConnectButton()
        updateMapView()
        
        //reconnect when changing countries
        if (VPNStatus == .disconnected && shouldVPNReconnect == true) {
            shouldVPNReconnect = false
            VPN.connect2VPN()
        }
    }
    
    @objc func connectButtonPressed(_ sender: Any) {
        //try to connect
        
//        guard AuthenticationService.shared.hasValidSubscription() == true else {
//            let text = NSLocalizedString("Your subscription has expired. Renew your subscription to continue to use the VPN.", tableName: "Lumen", comment: "[VPN] subscription expired alert text")
//            let alert = UIAlertController.alertWithOkay(text: text)
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
		
        if (NEVPNManager.shared().connection.status == .connected) {
            VPN.disconnectVPN()
        }
        else {
            VPN.connect2VPN()
        }
    }
    
    @objc func timerFired(_ sender: Timer) {
        
        func convert(num: Int?) -> String {
            
            var string = "00"
            
            if let s = num {
                if s < 10 {
                    string = "0\(String(s))"
                }
                else {
                    string = String(s)
                }
            }
            
            return string
        }
        
        if let fireDate = VPN.shared.connectDate {
            let comp = Set(arrayLiteral: Calendar.Component.second, Calendar.Component.hour, Calendar.Component.minute)
            let dateComponents = Calendar.current.dateComponents(comp, from: fireDate, to: Date())
            
            let seconds: String = convert(num: dateComponents.second)
            let minutes: String = convert(num: dateComponents.minute)
            let hours: String = convert(num: dateComponents.hour)
            
            let string = "\(hours):\(minutes):\(seconds)"
            connectButton.mainLabel.text = string
        }
    }
}

class CustomVPNCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VPNViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VPNCell", for: indexPath) as! CustomVPNCell
        
        //do the setup
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = NSLocalizedString("Choose VPN Location", tableName: "Lumen", comment: "[VPN] vpn choose location")
        cell.textLabel?.textColor = Lumen.VPN.selectTextColor(lumenTheme, .Normal)
        cell.backgroundColor = .clear
        cell.detailTextLabel?.text = VPNEndPointManager.shared.selectedCountry.name
        cell.detailTextLabel?.textColor = Lumen.VPN.selectDetailTextColor(lumenTheme, .Normal)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return countryButtonHeight
    }
}

extension VPNViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //push new view controller
        let countryVC = VPNCountryController()
        countryVC.delegate = self
        UIView.animate(withDuration: 0.1, animations: {
            self.view.alpha = 0.0
            self.navigationController?.pushViewController(countryVC, animated: true)
        })
    }
}

extension VPNViewController: VPNCountryControllerProtocol {
    func didSelectCountry(shouldReconnect: Bool) {
        if (VPN.shared.status == .connected && shouldReconnect) {
            //country changed
            //reconnect if necessary
            VPN.disconnectVPN()
            shouldVPNReconnect = true
        }
        //change the name of the country in the button
        self.tableView.reloadData()
    }
}

extension VPNViewController: Themeable {
    func applyTheme() {
        self.updateMapView()
        infoLabel.textColor = Lumen.VPN.infoLabelTextColor(lumenTheme, .Normal)
        upgradeView?.applyTheme()
        self.tableView.reloadData()
    }
    
}

extension VPNViewController : UpgradeLumenDelegate {
    func showUpgradeViewController() {
        let upgradLumenViewController = UpgradLumenViewController()
        self.present(upgradLumenViewController, animated: true, completion: nil)
    }
}

#endif
