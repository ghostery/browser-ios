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

protocol VPNViewControllerDelegate: class {
    func vpnOpenURLInNewTab(_ url: URL)
}
    
class VPNViewController: UIViewController {

    let tableView = UITableView()
    let mapView = UIImageView()
    let mapLabel = UILabel()
    weak var delegate: VPNViewControllerDelegate?
    
    let connectButton = VPNButton()
    lazy var vpnDefinitionButton: ButtonWithUnderlinedText = {
        let title = NSLocalizedString("VPN is short for Virtual Private Network", tableName: "Lumen", comment: "VPN definition")
        let action = NSLocalizedString("LEARN MORE", tableName: "Lumen", comment: "LEARN MORE action")
        let vpnDefinitionButton = ButtonWithUnderlinedText(startText: (title, UIColor.lumenTextBlue),
                                                           underlinedText: (action, UIColor.lumenTextBlue),
                                                           position: .bottom)
        vpnDefinitionButton.addTarget(self, action: #selector(openVPNLearnMore), for: .touchUpInside)
        return vpnDefinitionButton
    }()
    
    
    
    let countryButtonHeight: CGFloat = 50.0
    let vpnInfoView = VPNInfoView()
    
    var upgradeView: UpgradeView?
    var upgradeButton: ButtonWithUnderlinedText?
    let gradient = BrowserGradientView()
    
    var VPNStatus: NEVPNStatus {
        return VPN.shared.status
    }
    
    var timer: Timer? = nil
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// This is a trick to make VPN status update notifications work on the cold start
		NEVPNManager.shared().loadFromPreferences { (error) in
			if let e = error {
				print("Loading VPN Config failed: \(e.localizedDescription)")
			} else {
				print("Loading VPN Config Succeeded")
			}
		}
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
        updateVPNInfoView()
        
        LegacyTelemetryHelper.logVPN(action: "show")
    }
    
    @objc func handlePurchaseSuccessNotification(_ notification: Notification) {
        self.removeUpgradeView()
        self.removeUpgradeButton()
        setConstraints()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: true)
		self.view.alpha = 1.0
		updateMapView()
		updateConnectButton()
		updateVPNInfoView()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
    
    @objc func openVPNLearnMore() {
        if let url = URL(string: "https://lumenbrowser.com/faq.html#vpn") {
            self.delegate?.vpnOpenURLInNewTab(url)
        }
    }
    
    private func setupComponents() {
        tableView.register(CustomVPNCell.self, forCellReuseIdentifier: "VPNCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        
        connectButton.setTitleColor(.blue, for: .normal)
        connectButton.tintColor = .blue
        connectButton.addTarget(self, action: #selector(connectButtonPressed), for: .touchUpInside)

        mapLabel.text = NSLocalizedString("Active for all apps on this iPhone", tableName: "Lumen", comment: "VPN map label when it is ON")
        mapLabel.textColor = UIColor.white
        mapLabel.backgroundColor = UIColor.lumenDeepBlue
        mapLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        mapView.image = Lumen.VPN.mapImageActive(lumenTheme, .Normal)
        
        view.addSubview(gradient)
        view.addSubview(tableView)
        view.addSubview(mapView)
        view.addSubview(mapLabel)
        view.addSubview(vpnDefinitionButton)
        view.addSubview(connectButton)
        view.addSubview(vpnInfoView)
        
        #if PAID
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        switch currentSubscription {
        case .trial(_):
            if let trialRemainingDays = currentSubscription.trialRemainingDays(), trialRemainingDays < 4 {
                self.addUpgradeView()
            }
        case .limited:
            self.addUpgradeButton()
        default:
            break
        }
        #endif
    }
    
    private func addUpgradeView() {
        self.upgradeView = UpgradeView(view: "vpn")
        self.upgradeView?.delegate = self
        view.addSubview(upgradeView!)
    }
    
    private func removeUpgradeView() {
        upgradeView?.removeFromSuperview()
        upgradeView = nil
    }
    
    private func addUpgradeButton() {
        vpnDefinitionButton.removeFromSuperview()
        let title = NSLocalizedString("Unlock the VPN feature to get the best out of Lumen.", tableName: "Lumen", comment: "Unlock the VPN feature text")
        let action = NSLocalizedString("LEARN MORE", tableName: "Lumen", comment: "LEARN MORE action")
        upgradeButton = ButtonWithUnderlinedText(startText: (title, UIColor.theme.lumenSubscription.upgradeLabel),
                                                 underlinedText: (action, UIColor.lumenTextBlue),
                                                 position: .next,
                                                 view: "vpn")
        upgradeButton?.addTarget(self, action: #selector(showUpgradeViewController), for: .touchUpInside)
        self.view.addSubview(upgradeButton!)
    }
    
    private func removeUpgradeButton() {
        upgradeButton?.removeFromSuperview()
        upgradeButton = nil
        if vpnDefinitionButton.superview == nil {
            view.addSubview(vpnDefinitionButton)
        }
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
        vpnInfoView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(UIDevice.current.isSmallIphoneDevice() ? -10 : 0)
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(60)
        }
        
        mapView.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(tableView.snp.bottom)
        }
        
        mapLabel.snp.remakeConstraints { (make) in
            make.centerY.centerX.equalTo(mapView)
        }
        
        
        if let upgradeButton = self.upgradeButton {
            connectButton.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(upgradeButton.snp.top).offset(UIDevice.current.isSmallIphoneDevice() ? -6 : -16)
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
                make.bottom.equalTo(vpnDefinitionButton.snp.top).offset(UIDevice.current.isSmallIphoneDevice() ? -6: -16)
            }
            vpnDefinitionButton.snp.remakeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-26)
                make.width.equalToSuperview().dividedBy(1.25)
                make.centerX.equalToSuperview()
                //I should not set the height. Quick fix.
                make.height.equalTo(40)
            }
        }
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setStyling() {
//        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.separatorColor = .clear
        mapView.contentMode = .scaleAspectFill
    }
    
    func updateConnectButton() {
        
        if VPNStatus == .connected {
            self.connectButton.set(state: .Disconnect)
            //start timer
            timer = Timer.scheduledTimer(timeInterval: 0.95, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            timer?.fire()
            LegacyTelemetryHelper.logVPN(action: "connect",
                                         location: VPNEndPointManager.shared.selectedCountry.id)
        }
        else if VPNStatus == .disconnected {
            if self.connectButton.currentState == .Connecting || self.connectButton.currentState == .Connect {
                self.connectButton.set(state: .Retry)
            }
            self.connectButton.set(state: .Connect)
            timer?.invalidate()
            timer = nil
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
            mapView.alpha = 1
            mapLabel.isHidden = false
        }
        else {
            //inactive image
            mapView.alpha = 0.3
            mapLabel.isHidden = true
        }
    }
    
    func updateVPNInfoView() {
        self.vpnInfoView.updateView(VPNStatus == .connected)
    }

    
    @objc func VPNStatusDidChange(notification: Notification) {
        //keep button up to date.
        updateVPNInfoView()
        updateConnectButton()
        updateMapView()
    }
    
    @objc func connectButtonPressed(_ sender: Any) {
        if (VPN.shared.status == .connected) {
            VPN.disconnectVPN()
            LegacyTelemetryHelper.logVPN(action: "click", target: "toggle", state: "off")
            
            LegacyTelemetryHelper.logVPN(action: "disconnect",
                                         location: VPNEndPointManager.shared.selectedCountry.id,
                                         connectionTime: getConnectionTime())
        } else {
            guard SubscriptionController.shared.isVPNEnabled() else {
                displayUnlockVPNAlert()
                return
            }
            VPN.connect2VPN()
            LegacyTelemetryHelper.logVPN(action: "click", target: "toggle", state: "on")
        }
    }
    
    private func isFirstConnection() -> Bool {
        let alreadyConnectedBeforeKey = "VPN.Connection.first"
        let alreadyConnectedBefore = UserDefaults.standard.bool(forKey: alreadyConnectedBeforeKey)
        UserDefaults.standard.set(true, forKey: alreadyConnectedBeforeKey)
        return !alreadyConnectedBefore
    }
    
    private func getConnectionTime() -> Int? {
        guard let connectDate = VPN.shared.connectDate else { return nil }
        return Int(Date().timeIntervalSince(connectDate))
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
        let cancelAction = UIAlertAction(title: NSLocalizedString("No, Thanks", tableName: "Lumen", comment: "`No, Thanks` alert button"), style: .default) { (action) in
            LegacyTelemetryHelper.logMessage(action: "click", topic: "upgrade", style: "dialogue", view: "vpn", target: "cancel")
        }
        alert.addAction(cancelAction)
        
        
        let okAction = UIAlertAction(title: NSLocalizedString("Learn More", tableName: "Lumen", comment: "`Learn More` alert button"), style: .default) { [weak self](action) in
            self?.showUpgradeViewController()
            LegacyTelemetryHelper.logMessage(action: "click", topic: "upgrade", style: "dialogue", view: "vpn", target: "upgrade")
        }
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
        LegacyTelemetryHelper.logMessage(action: "show", topic: "upgrade", style: "dialogue", view: "vpn")
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
        self.navigationController?.pushViewController(countryVC, animated: true)
    }
}

extension VPNViewController: VPNCountryControllerProtocol {
    func didSelectCountry(country: VPNCountry) {
        LegacyTelemetryHelper.logVPN(action: "click",
                                     target: "location",
                                     location: VPNEndPointManager.shared.selectedCountry.id)
        //country changed, reconnect if necessary
        VPN.countryDidChange(country: country)
        
        //change the name of the country in the button
        self.tableView.reloadData()
    }
}

extension VPNViewController: Themeable {
    func applyTheme() {
        self.updateMapView()
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
