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


class BondClient {
    static let shared = BondClient()
    
    let client: BondV1
    
    static let hostname: String = "ambassador.dev.k8s.eu-central-1.clyqz.com"
    
    init() {
        client = BondV1.init(host: BondClient.hostname)
    }
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
        if (status == .disconnected && shouldTryToReconnect) {
            VPN.connect2VPN()
        }
    }
    
    static func disconnectVPN() {
        VPN.shared.shouldTryToReconnect = false
        NEVPNManager.shared().connection.stopVPNTunnel()
    }
    
    static func connect2VPN() {
        
        VPN.shared.shouldTryToReconnect = true
        
        let country = VPNEndPointManager.shared.selectedCountry
        guard let creds = VPNEndPointManager.shared.selectedCountry.getCredentials() else { return }
        
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
                
                NEVPNManager.shared().protocolConfiguration = newIPSec
                NEVPNManager.shared().isOnDemandEnabled = true
                NEVPNManager.shared().isEnabled = true
                NEVPNManager.shared().saveToPreferences(completionHandler: { (error) in
                    try? NEVPNManager.shared().connection.startVPNTunnel()
                })
            }
            else {
                NEVPNManager.shared().isEnabled = true;
                try? NEVPNManager.shared().connection.startVPNTunnel()
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
        
        func getCredentials() -> Credentials? {
            let keychain = DAKeychain.shared
            if let username = keychain[usernameHash],
                let pass = keychain.load(withKey: passwordHash),
                let sharedS = keychain.load(withKey: sharedSecretHash)
            {
                return Credentials(username: username, password: pass, sharedSecret: sharedS)
            }
            
            return nil
        }
        
        func setCreds(username: String, password: String, sharedSecret: String) {
            let keychain = DAKeychain.shared
            keychain[usernameHash] = username
            keychain[passwordHash] = password
            keychain[sharedSecretHash] = sharedSecret
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
    
    static let defaultCountry = VPNCountry(id: "de", name: "Germany", endpoint: "195.181.170.100")
    
    //list of possible countries. Each country has its own credentials and endpoints
    var countries: [VPNCountry] = [
        VPNCountry(id: "us", name: "United States", endpoint: "195.181.168.14"),
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
        let auth = UserAuth()
        auth.username = "test@cliqz.com"
        auth.password = "uk4lj2m8jqcclbzi80itb6"
        BondClient.shared.client.getIPSecCreds(withRequest: auth) { [weak self] (response, error) in
            //TODO: write the credentials into the keychain
            if let config = response?.config as? [String: IPSecConfig] {
                for (key, value) in config {
                    if let country = self?.country(id: key) {
                        country.setCreds(username: value.username, password: value.password, sharedSecret: value.secret)
                    }
                }
            }
        }
    }
    
    func country(id: String) -> VPNCountry? {
        return countries.filter{$0.id == id}.first
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
    
    var VPNStatus: NEVPNStatus {
        return VPN.shared.status;
    }
    
    var timer: Timer? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(mapView)
        view.addSubview(infoLabel)
        view.addSubview(connectButton)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(CustomVPNCell.self, forCellReuseIdentifier: "VPNCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.topMargin)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(countryButtonHeight)
        }
        
        tableView.isScrollEnabled = false
        
        updateMapView()
        mapView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(tableView.snp.bottom).offset(20)
        }
        
        updateConnectButton()
        connectButton.setTitleColor(.blue, for: .normal)
        connectButton.tintColor = .blue
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)
        
        connectButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(infoLabel.snp.top).offset(-16)
        }
        
        infoLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-26)
            make.width.equalToSuperview().dividedBy(1.25)
            make.centerX.equalToSuperview()
        }
        
        infoLabel.text = "Turn on VPN protection to browse safely on the Internet."
        
        setStyling()
    }
    
    func setStyling() {
        self.view.backgroundColor = VPNUX.bgColor
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        infoLabel.textColor = VPNUX.cliqzBlue
        infoLabel.font = UIFont.systemFont(ofSize: 14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
            mapView.image = UIImage(named: "VPNMapActive")
        }
        else {
            //inactive image
            mapView.image = UIImage(named: "VPNMapInactive")
        }
    }
    
    @objc func VPNStatusDidChange(notification: Notification) {
        //keep button up to date.
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
        cell.textLabel?.text = "Connect to:"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .clear
        cell.detailTextLabel?.text = VPNEndPointManager.shared.selectedCountry.name
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
        self.navigationController?.pushViewController(countryVC, animated: true)
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

#endif
