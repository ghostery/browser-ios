//
//  VPNViewController.swift
//  VPNViews
//
//  Created by Tim Palade on 10/26/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit
import NetworkExtension

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
    
    let lastEndPointKey = "VPNLastEndPointKey"
    var lastEndPoint: String {
        set {
            UserDefaults.standard.set(newValue, forKey: lastEndPointKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let value = UserDefaults.standard.value(forKey: lastEndPointKey) as? String {
                return value
            }
            
            return "" //default
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
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
    }
    
    func checkConnection() {
        if (lastStatus == .connected && status != .connected) {
            VPN.connect2VPN(endPoint: lastEndPoint)
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
            VPN.connect2VPN(endPoint: lastEndPoint)
        }
    }
    
    static func disconnectVPN() {
        VPN.shared.shouldTryToReconnect = false
        NEVPNManager.shared().connection.stopVPNTunnel()
    }
    
    static func connect2VPN(endPoint: String) {
        
        VPN.shared.shouldTryToReconnect = true
        VPN.shared.lastEndPoint = endPoint
        
        //Insert credentials into Keychain
        let username = "cliqz"
        
        guard let password = Bundle.main.object(forInfoDictionaryKey: "VPNPass") as? String, !password.isEmpty else {
            //send a signal
            return
        }
        
        //TODO: This should be done better.
        let keychain = DAKeychain.shared
        keychain[username] = password
        keychain["sharedSecret"] = "foxyproxy"
        
        NEVPNManager.shared().loadFromPreferences { (error) in
            if NEVPNManager.shared().protocolConfiguration == nil || NEVPNManager.shared().protocolConfiguration?.serverAddress != endPoint {
                let newIPSec = NEVPNProtocolIPSec()
                //setUp the protocol
                newIPSec.useExtendedAuthentication = true
                
                newIPSec.authenticationMethod = .sharedSecret
                newIPSec.sharedSecretReference = keychain.load(withKey: "sharedSecret")
                
                newIPSec.username = "cliqz"
                newIPSec.passwordReference = keychain.load(withKey: username)
                newIPSec.serverAddress = endPoint;
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

struct VPNUX {
    static let bgColor = UIColor(red:0.08, green:0.10, blue:0.11, alpha:1.00)
    static let cliqzBlue = UIColor(red: 7/255, green: 230/255, blue: 254/255, alpha: 1.0)
    static let secondaryBlue = UIColor(red:0.00, green:0.61, blue:0.92, alpha:1.00)
}

public enum VPNCountry: Int {
    case Germany
    case USA
    
    func toString() -> String {
        switch self {
        case .Germany:
            return "Germany"
        default:
            return "United States"
        }
    }
    
    func endPoint() -> String {
        switch self {
        case .Germany:
            return "195.181.170.100"
        default:
            return "195.181.168.14"
        }
    }
    
    static func country(string: String) -> VPNCountry {
        if string == VPNCountry.Germany.toString() {
            return .Germany
        }
        else {
            return .USA
        }
    }
}

class VPNViewController: UIViewController {
    
    //save this to userdefaults
    let selectedCountryKey = "VPNSelectedCountry"
    
    var selectedCountry: VPNCountry {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: selectedCountryKey)
            UserDefaults.standard.synchronize()
        }
        get {
            if let countryRaw = UserDefaults.standard.value(forKey: selectedCountryKey) as? Int {
                if let country = VPNCountry(rawValue: countryRaw) {
                    return country
                }
            }
            
            return .Germany //default
        }
    }
    
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
            if connectDate == nil {
                connectDate = Date()
            }
        }
        else if VPNStatus == .disconnected {
            if self.connectButton.currentState == .Connecting || self.connectButton.currentState == .Connect {
                self.connectButton.set(state: .Retry)
            }
            self.connectButton.set(state: .Connect)
            timer?.invalidate()
            timer = nil
            connectDate = nil
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
        
        if (VPNStatus == .disconnected && shouldVPNReconnect == true) {
            shouldVPNReconnect = false
            VPN.connect2VPN(endPoint: self.selectedCountry.endPoint())
        }
    }
    
    @objc func connectButtonPressed(_ sender: Any) {
        //try to connect
        
        if (NEVPNManager.shared().connection.status == .connected) {
            VPN.disconnectVPN()
        }
        else {
            VPN.connect2VPN(endPoint: self.selectedCountry.endPoint())
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
        
        if let fireDate = connectDate {
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
        cell.detailTextLabel?.text = selectedCountry.toString()
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
        countryVC.selectedCountry = selectedCountry
        countryVC.delegate = self
        self.navigationController?.pushViewController(countryVC, animated: true)
    }
}

extension VPNViewController: VPNCountryControllerProtocol {
    func didSelectCountry(country: VPNCountry) {
        
        if (country != selectedCountry) {
            //country changed
            //reconnect if necessary
            VPN.disconnectVPN()
            shouldVPNReconnect = true
        }
        selectedCountry = country
        //change the name of the country in the button
        self.tableView.reloadData()
    }
}
