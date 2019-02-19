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
        guard SubscriptionController.shared.isVPNEnabled() else {
            VPN.disconnectVPN()
            NEVPNManager.shared().removeFromPreferences { (error) in
                if let e = error {
                    print("Could not remove VPN configurations, with the following error: \(e.localizedDescription)")
                }
            }
            return
        }
        
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
			let ikeProtocol = NEVPNProtocolIKEv2()
			ikeProtocol.authenticationMethod = .none
			ikeProtocol.username = creds.username
			ikeProtocol.passwordReference = creds.password
			ikeProtocol.serverAddress = country.endpoint
			ikeProtocol.remoteIdentifier = country.remoteID
			ikeProtocol.useExtendedAuthentication = true
			ikeProtocol.childSecurityAssociationParameters.encryptionAlgorithm = .algorithmAES256
			ikeProtocol.childSecurityAssociationParameters.integrityAlgorithm = .SHA256
			ikeProtocol.disconnectOnSleep = false

			//Need to figure out how to do this properly. If we do it like this it will say that the configuration is invalid.
//                let alwaysConnected = NEOnDemandRule()
//                alwaysConnected.interfaceTypeMatch = .any
//                NEVPNManager.shared().onDemandRules = [alwaysConnected]
			NEVPNManager.shared().protocolConfiguration = ikeProtocol
			NEVPNManager.shared().isOnDemandEnabled = true
			NEVPNManager.shared().isEnabled = true

			NEVPNManager.shared().saveToPreferences(completionHandler: { (error) in
				do {
					try NEVPNManager.shared().connection.startVPNTunnel()
				}
				catch (let error) {
					print("VPN Connecttion failed --- \(error)")
					VPN.shared.shouldTryToReconnect = false
				}
			})
        }
    }
}

class VPNEndPointManager {
    //manages the endpoints and credentials for each country
    
    struct Credentials {
        let username: String
        let password: Data
//        let sharedSecret: Data
    }
    
    class VPNCountry: Codable, Equatable {
        let id: String //id from the server
        let name: String //display name
        var endpoint: String //endpoint address
		var remoteID: String //endpoint address

		init(id: String, name: String, endpoint: String, remoteID: String) {
			self.id = id
			self.name = name
			self.endpoint = endpoint
			self.remoteID = remoteID
		}

        static func == (lhs: VPNCountry, rhs: VPNCountry) -> Bool {
            return lhs.id == rhs.id
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
        
    }
    
    static let defaultCountryIndex = 1
    
    //list of possible countries. Each country has its own credentials and endpoints
    var countries: [VPNCountry] = [
		VPNCountry(id: "us", name: NSLocalizedString("USA", tableName: "Lumen", comment: "VPN country name for USA"), endpoint: "", remoteID: ""),
		VPNCountry(id: "de", name: NSLocalizedString("Germany", tableName: "Lumen", comment: "VPN country name for Germany"), endpoint: "", remoteID: "")
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
            return countries[VPNEndPointManager.defaultCountryIndex] // VPNEndPointManager.defaultCountry //default
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
				if let country = self?.country(id: cred.country.lowercased()) {
					self?.setCreds(country: country, username: cred.username, password: cred.password)
					country.endpoint = cred.serverIP
					country.remoteID = cred.remoteID
				}
			}
		}
    }
    
    func country(id: String) -> VPNCountry? {
        return countries.filter{$0.id == id}.first
    }
    
    func getCredentials(country: VPNCountry) -> Credentials? {
        let keychain = DAKeychain.shared
        if let username = keychain[country.usernameHash],
            let pass = keychain.load(withKey: country.passwordHash)
        {
            return Credentials(username: username, password: pass)
        }
        //initiate a call to get the credentials?
        getVPNCredentialsFromServer()
        return nil
    }
    
    private func setCreds(country: VPNCountry, username: String, password: String) {
        let keychain = DAKeychain.shared
        keychain[country.usernameHash] = username
        keychain[country.passwordHash] = password
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
    var upgradeButton: ButtonWithUnderlinedText?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseSuccessNotification(_:)),
                                               name: .ProductPurchaseSuccessNotification,
                                               object: nil)
        
        setupComponents()
        setConstraints()
        setStyling()
        
        updateMapView()
        updateConnectButton()
        updateInfoLabel()
    }
    
    @objc func handlePurchaseSuccessNotification(_ notification: Notification) {
        upgradeView?.removeFromSuperview()
        upgradeView = nil
        upgradeButton?.removeFromSuperview()
        upgradeButton = nil
        setConstraints()
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
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        switch currentSubscription {
        case .trial(_):
            if let trialRemainingDays = currentSubscription.trialRemainingDays(), trialRemainingDays < 8 {
                self.upgradeView = UpgradeView()
                self.upgradeView?.delegate = self
                view.addSubview(upgradeView!)
            }
        case .limited:
            infoLabel.removeFromSuperview()
            let title = NSLocalizedString("Unlock the VPN feature to get the best out of Lumen.", tableName: "Lumen", comment: "Unlock the VPN feature text")
            let action = NSLocalizedString("LEARN MORE", tableName: "Lumen", comment: "LEARN MORE action")
            upgradeButton = ButtonWithUnderlinedText(startText: (title, UIColor.theme.lumenSubscription.upgradeLabel), underlinedText: (action, UIColor.lumenBrightBlue), position: .next)
            upgradeButton?.addTarget(self, action: #selector(showUpgradeViewController), for: .touchUpInside)
            self.view.addSubview(upgradeButton!)
        default:
            break
        }
        #endif
    }
    
    private func setConstraints() {
        if let upgradeView = self.upgradeView {
            upgradeView.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(UpgradeViewUX.height)
            }
            tableView.snp.remakeConstraints { (make) in
                make.top.equalTo(upgradeView.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(countryButtonHeight)
            }
        } else {
            tableView.snp.remakeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(countryButtonHeight)
            }
        }
        
        mapView.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(tableView.snp.bottom).offset(20)
        }
        
        
        if let upgradeButton = self.upgradeButton {
            connectButton.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(upgradeButton.snp.top).offset(-16)
            }
            upgradeButton.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-26)
                make.width.equalToSuperview().dividedBy(1.25)
                make.centerX.equalToSuperview()
                //I should not set the height. Quick fix.
                make.height.equalTo(40)
            }
        } else {
            connectButton.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(infoLabel.snp.top).offset(-16)
            }
            infoLabel.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-26)
                make.width.equalToSuperview().dividedBy(1.25)
                make.centerX.equalToSuperview()
                //I should not set the height. Quick fix.
                make.height.equalTo(40)
            }
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
        let retryText = NSLocalizedString("Oh, something went wrong. Please try again.", tableName: "Lumen", comment: "VPN retry text")
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
        guard SubscriptionController.shared.isVPNEnabled() else {
            displayUnlockVPNAlert()
            return
        }
		
        if (NEVPNManager.shared().connection.status == .connected) {
            VPN.disconnectVPN()
        } else {
			shouldVPNReconnect = true
            VPN.connect2VPN()
        }
    }
    private func displayUnlockVPNAlert () {
        let title = NSLocalizedString("VPN Protection.", tableName: "Lumen", comment: "[VPN] subscription expired alert title")
        let text = NSLocalizedString("Unlock the VPN feature to get the best out of Lumen.", tableName: "Lumen", comment: "[VPN] subscription expired alert text")
        let alert = UIAlertController(
            title: title,
            message: text,
            preferredStyle: .alert
        )
        
        //Learn More
        let cancelAction = UIAlertAction(title: NSLocalizedString("No, Thanks", tableName: "Lumen", comment: "`No, Thanks` alert button"), style: .default, handler: nil)
        alert.addAction(cancelAction)
        
        
        let okAction = UIAlertAction(title: NSLocalizedString("Learn More", tableName: "Lumen", comment: "`Learn More` alert button"), style: .default) { [weak self](action) in
            self?.showUpgradeViewController()
        }
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
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
    @objc func showUpgradeViewController() {
        let upgradLumenViewController = UpgradLumenViewController()
        self.present(upgradLumenViewController, animated: true, completion: nil)
    }
}

#endif
