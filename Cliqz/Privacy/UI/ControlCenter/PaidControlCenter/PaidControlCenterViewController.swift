//
//  PaidControlCenterViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 10/18/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

#if PAID
import UIKit

extension Notification.Name {
    static let themeChanged = Notification.Name("LumenThemeChanged")
}

var lumenTheme: LumenThemeName {
    
    if (UIColor.theme.name == "dark") {
        return .Dark
    }
    
    return .Light
}

var lumenDashboardMode: LumenThemeMode = UserPreferences.instance.isProtectionOn ? .Normal : .Disabled

class PaidControlCenterViewController: ControlCenterViewController {
    
    var upgradeView: UpgradeView?
    let controls = CCControlsView()
    let tabs = UISegmentedControl(items: [NSLocalizedString("Today", tableName: "Lumen", comment:"[Lumen->Dashboard] Today tab"),
                                          NSLocalizedString("Last 7 days", tableName: "Lumen", comment:"[Lumen->Dashboard] Last 7 days tab")])
    let protectionLabel = UILabel()
    
    let dashboard = CCCollectionViewController()
    let cellDataSource = CCDataSource()
    
    let protectionOn = NSLocalizedString("Ultimate Protection: ON", tableName: "Lumen", comment:"[Lumen->Dashboard] Security Status ON")
    let protectionOff = NSLocalizedString("Ultimate Protection: OFF", tableName: "Lumen", comment:"[Lumen->Dashboard] Security Status OFF")
    
    let protectionOnColor = Lumen.Dashboard.protectionLabelColor(lumenTheme, lumenDashboardMode)
    let protectionOffColor = Lumen.Dashboard.protectionLabelColor(lumenTheme, lumenDashboardMode)
    
    var currentPeriod: Period = .Today
    
    override func setupComponents() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        controls.delegate = self
        dashboard.dataSource = cellDataSource
        
        self.addChildViewController(dashboard)
        self.view.addSubview(controls)
        self.view.addSubview(tabs)
        self.view.addSubview(protectionLabel)
        self.view.addSubview(dashboard.view)
        
        tabs.selectedSegmentIndex = 0
        tabs.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        #if PAID
        if let trialRemainingDays = SubscriptionController.shared.getCurrentSubscription().trialRemainingDays() {
            //TODO: add condition `trialRemainingDays < 8`
            //TODO: Implement UpgradeViewDelegate
            self.upgradeView = UpgradeView()
            view.addSubview(upgradeView!)
        }
        #endif
        setConstraints()
        setStyle()
        
        updateProtectionLabel(isOn: UserPreferences.instance.isProtectionOn)
        updateVPNButton()
        
        CCWidgetManager.shared.update(period: currentPeriod)
    }
    
    private func setConstraints() {
        if let upgradeView = self.upgradeView {
            upgradeView.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview().inset(10)
                make.height.equalTo(UpgradeViewUX.height)
            }
        }
        controls.snp.makeConstraints { (make) in
            if let upgradeView = self.upgradeView {
                make.top.equalTo(upgradeView.snp.bottom).offset(10)
            } else {
                make.top.equalToSuperview().offset(10)
            }
            
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(100)
        }
        
        tabs.snp.makeConstraints { (make) in
            make.top.equalTo(controls.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
        }
        
        protectionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tabs.snp.bottom).offset(12)
            make.trailing.leading.equalToSuperview()
        }
        
        dashboard.view.snp.makeConstraints { (make) in
            make.top.equalTo(protectionLabel.snp.bottom).offset(10)
            make.trailing.leading.bottom.equalToSuperview()
        }
    }
    func setStyle() {
        protectionLabel.textAlignment = .center
        protectionLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        self.view.backgroundColor = Lumen.Dashboard.backgroundColor(lumenTheme, lumenDashboardMode).withAlphaComponent(Lumen.Dashboard.backgroundColorAlpha(lumenTheme))
        tabs.tintColor = Lumen.Dashboard.segmentedControlColor(lumenTheme, lumenDashboardMode)
        controls.vpnButton.isSelected = VPN.shared.status == .connected
    }
    
    func updateProtectionLabel(isOn: Bool) {
        if isOn {
            protectionLabel.text = protectionOn
            protectionLabel.textColor = protectionOnColor
        }
        else {
            protectionLabel.text = protectionOff
            protectionLabel.textColor = protectionOffColor
        }
    }
    
    
    func updateVPNButton() {
        controls.vpnButton.isSelected = VPN.shared.status == .connected
    }
    
    @objc func tabChanged(_ segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            currentPeriod = .Today
        }
        else if segmentedControl.selectedSegmentIndex == 1 {
            currentPeriod = .Last7Days
        }
        
        CCWidgetManager.shared.update(period: currentPeriod)
    }
    
    @objc func VPNStatusDidChange(notification: Notification) {
        //keep button up to date.
        updateVPNButton()
    }

}

extension PaidControlCenterViewController: CCControlViewProtocol {
    func vpnButtonPressed() {
        if let appDel = UIApplication.shared.delegate as? AppDelegate, let tab = appDel.tabManager.selectedTab {
            //open vpn view
            tab.loadRequest(PrivilegedRequest(url: HomePanelType.bookmarks.localhostURL) as URLRequest)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { //[weak self] in
                self.delegate?.dismiss()
            }
        }
    }
    
    func startButtonPressed() {
        UserPreferences.instance.isProtectionOn = !UserPreferences.instance.isProtectionOn
        lumenDashboardMode = UserPreferences.instance.isProtectionOn ? .Normal : .Disabled
        
        updateProtectionLabel(isOn: UserPreferences.instance.isProtectionOn)
        dashboard.update()
    }
    
    func clearButtonPressed() {
        
        func clearDashboardData(_ action: UIAlertAction) {
            DispatchQueue.global(qos: .utility).async { [weak self] in
                //print("Will send data for tab = \(tabID) and page = \(String(describing: currentP))")
                Engine.sharedInstance.getBridge().callAction(JSBridge.Action.cleanData.rawValue, args: [], callback: { (result) in
                    if let error = result["error"] as? [[String: Any]] {
                        debugPrint("Error calling action insights:clearData: \(error)")
                        //TODO: What should I do in this case?
                    }
                    else {
                        CCWidgetManager.shared.update(period: self?.currentPeriod ?? .Today)
                    }
                })
            }
        }
        
        let alertText = NSLocalizedString("This will delete all your dashboard data and cannot be undone.", tableName: "Lumen", comment: "Lumen Clear Dashboard Data Popup Text")
        let actionTitle = NSLocalizedString("Clear", tableName: "Lumen", comment: "Lumen Clear Dashboard Data Popup Clear Button Text")
        let alert = UIAlertController.alertWithCancelAndAction(text: alertText, actionButtonTitle: actionTitle, isActionDestructive: true,actionCallback: clearDashboardData)
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            appDel.presentContollerOnTop(controller: alert)
        }
    }
    
}

protocol CCControlViewProtocol: class {
    func vpnButtonPressed()
    func startButtonPressed()
    func clearButtonPressed()
}

class CCControlsView: UIView {
    
    let vpnButton = UIButton()
    let startButton = UIButton()
    let clearButton = UIButton()
    let stackView = UIStackView()
    
    let startLabel = UILabel()
    let clearLabel = UILabel()
    let vpnLabel = UILabel()
    
    let startContainer = UIView()
    let clearContainer = UIView()
    let vpnContainer = UIView()
    
    func startLabelTitle(isSelected: Bool) -> String {
        if isSelected == false {
            return NSLocalizedString("Pause", tableName: "Lumen", comment:"[Lumen->Dashboard] Pause button")
        }
        else {
            return NSLocalizedString("Start", tableName: "Lumen", comment:"[Lumen->Dashboard] Start button")
        }
    }
    
    weak var delegate: CCControlViewProtocol? = nil
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.addArrangedSubview(startContainer)
        stackView.addArrangedSubview(vpnContainer)
        stackView.addArrangedSubview(clearContainer)
        
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.alignment = .center
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        setUpContainer(container: startContainer, button: startButton, label: startLabel)
        setUpContainer(container: vpnContainer, button: vpnButton, label: vpnLabel)
        setUpContainer(container: clearContainer, button: clearButton, label: clearLabel)
        
        startLabel.text = startLabelTitle(isSelected: !UserPreferences.instance.isProtectionOn)
        vpnLabel.text = NSLocalizedString("VPN", tableName: "Lumen", comment:"[Lumen->Dashboard] VPN button")
        clearLabel.text = NSLocalizedString("Clear", tableName: "Lumen", comment:"[Lumen->Dashboard] Clear button")
        
        startLabel.textColor = Lumen.Dashboard.buttonTitleColor(lumenTheme, lumenDashboardMode)
        vpnLabel.textColor = Lumen.Dashboard.buttonTitleColor(lumenTheme, lumenDashboardMode)
        clearLabel.textColor = Lumen.Dashboard.buttonTitleColor(lumenTheme, lumenDashboardMode)
        
        startLabel.textAlignment = .center
        vpnLabel.textAlignment = .center
        clearLabel.textAlignment = .center
        
        startButton.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: UILayoutConstraintAxis(rawValue: 1000)!)
        
        vpnButton.setImage(Lumen.Dashboard.VPNButtonImage(lumenTheme, lumenDashboardMode), for: .normal)
        vpnButton.setImage(Lumen.Dashboard.VPNButtonImageSelected(lumenTheme, lumenDashboardMode), for: .selected)
        
        startButton.setImage(Lumen.Dashboard.startButtonImage(lumenTheme, lumenDashboardMode), for: .normal)
        startButton.setImage(Lumen.Dashboard.startButtonImageSelected(lumenTheme, lumenDashboardMode), for: .selected)
        
        clearButton.setImage(Lumen.Dashboard.clearButtonImage(lumenTheme, lumenDashboardMode), for: .normal)
        
        vpnButton.addTarget(self, action: #selector(vpnPressed), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startPressed), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearPressed), for: .touchUpInside)
        
        startButton.isSelected = !UserPreferences.instance.isProtectionOn
        vpnButton.isSelected = VPN.shared.status == .connected
    }
    
    func setUpContainer(container: UIView, button: UIButton, label: UILabel) {
        container.addSubview(button)
        container.addSubview(label)
        
        button.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.bottom.equalTo(label.snp.top)
            make.centerX.equalToSuperview()
        }
        
        label.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        container.snp.makeConstraints { (make) in
            make.width.equalTo(button.snp.width)
        }
    }
    
    @objc func vpnPressed(_ button: UIButton) {
        //button.isSelected = !button.isSelected
        delegate?.vpnButtonPressed()
    }
    
    @objc func startPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        startLabel.text = startLabelTitle(isSelected: button.isSelected)
        delegate?.startButtonPressed()
    }
    
    @objc func clearPressed(_ button: UIButton) {
        button.isSelected = !button.isSelected
        delegate?.clearButtonPressed()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
