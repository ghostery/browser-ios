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

let lumenThemeKey = "LumenThemeKey"
var lumenTheme: LumenThemeName {
    
    if (SettingsPrefs.shared.getLumenTheme() == true) {
        return .Dark
    }
    
    return .Light
}

let lumenDashboardMode: LumenThemeMode = .Normal

class PaidControlCenterViewController: ControlCenterViewController {
    
    let controls = CCControlsView()
    let tabs = UISegmentedControl(items: ["Heute", "Letzte 7 Tage"])
    let protectionLabel = UILabel()
    
    let dashboard = CCCollectionViewController()
    let cellDataSource = CCDataSource()
    
    let protectionOn = "Komplettschutz: EIN"
    let protectionOff = "Komplettschutz: AUS"
    
    let protectionOnColor = Lumen.Dashboard.protectionLabelColor(lumenTheme, lumenDashboardMode)
    let protectionOffColor = Lumen.Dashboard.protectionLabelColor(lumenTheme, lumenDashboardMode)
    
    var currentPeriod: Period = .Today
    
    fileprivate lazy var clearables: [Clearable] = {
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate, let tabManager = appDel.tabManager, let profile = appDel.profile {
            return [HistoryClearable(profile: profile),
                    CacheClearable(tabManager: tabManager),
                    CookiesClearable(tabManager: tabManager),
                    SiteDataClearable(tabManager: tabManager),
                    DownloadedFilesClearable()]
        }
        
        return []
    }()
    
    override func setupComponents() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VPNStatusDidChange(notification:)),
                                               name: .NEVPNStatusDidChange,
                                               object: nil)
        
        controls.delegate = self
        dashboard.dataSource = self
        
        self.addChildViewController(dashboard)
        self.view.addSubview(controls)
        self.view.addSubview(tabs)
        self.view.addSubview(protectionLabel)
        self.view.addSubview(dashboard.view)
        
        tabs.selectedSegmentIndex = 0
        tabs.addTarget(self, action: #selector(tabChanged), for: .valueChanged)
        
        controls.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
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
        
        setStyle()
        
        updateProtectionLabel(isOn: UserPreferences.instance.isProtectionOn)
        updateVPNButton()
        
        CCWidgetManager.shared.update(period: currentPeriod)
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
        updateProtectionLabel(isOn: UserPreferences.instance.isProtectionOn)
    }
    
    func clearButtonPressed() {
        let alert = UIAlertController.clearPrivateDataAlert(okayCallback: clearPrivateData)
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            appDel.presentContollerOnTop(controller: alert)
        }
    }
    
    func clearPrivateData(_ action: UIAlertAction) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            //print("Will send data for tab = \(tabID) and page = \(String(describing: currentP))")
            Engine.sharedInstance.getBridge().callAction("insights:clearData", args: [], callback: { (result) in
                if let error = result["error"] as? [[String: Any]] {
                    debugPrint("Error calling action insights:clearData: \(error)")
                    //TODO: What should I do in this case?
                }
                else {
//                    DispatchQueue.main.async {
//                        self?.clearables
//                            .enumerated()
//                            .compactMap { (i, clearable) in
//                                return clearable.clear()
//                            }
//                            .allSucceed()
//                            .uponQueue(.main) { result in
//                                assert(result.isSuccess, "Private data cleared successfully")
//                                //TODO: Change UI
//
//                        }
//                    }
                    CCWidgetManager.shared.update(period: self?.currentPeriod ?? .Today)
                }
            })
        }
    }
}

extension PaidControlCenterViewController: CCCollectionDataSourceProtocol {
    func numberOfRows() -> Int {
        return cellDataSource.numberOfCells() - 1
    }
    
    func heightFor(index: Int) -> CGFloat {
        if index == 0 {
            return cellDataSource.heightFor(index: 0)
        }
        return cellDataSource.heightFor(index: index + 1)
    }
    
    func cellFor(index: Int) -> UIView {
        if index == 0 {
            let v = UIStackView()
            
            v.axis = .horizontal
            //v.spacing = 10
            v.distribution = .equalSpacing
            
            let c1 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            let c2 = CCVerticalCell(widgetRatio: CCUX.VerticalContentWidgetRatio, descriptionRatio: 1 - CCUX.VerticalContentWidgetRatio)
            
            v.addArrangedSubview(c1)
            v.addArrangedSubview(c2)
            
            c1.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            c2.snp.makeConstraints { (make) in
                make.width.equalToSuperview().dividedBy(2).offset(-5)
                make.height.equalToSuperview()
            }
            
            cellDataSource.configureCell(cell: c1, index: 0, period: currentPeriod)
            cellDataSource.configureCell(cell: c2, index: 1, period: currentPeriod)
            
            return v
        }
        
        let cell = CCHorizontalCell(widgetRatio: CCUX.HorizontalContentWigetRatio,
                                    descriptionRatio: 1 - CCUX.HorizontalContentWigetRatio,
                                    optionalView: cellDataSource.optionalView(index: index + 1),
                                    optionalViewHeight: cellDataSource.optionalViewHeight(index: index + 1))
        
        cellDataSource.configureCell(cell: cell, index: index + 1, period: currentPeriod)
        
        return cell
    }
    
    func cellSpacing() -> CGFloat {
        return 22.0
    }
    
    func horizontalPadding() -> CGFloat {
        return 20
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
            return "Pause"
        }
        else {
            return "Start"
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
        vpnLabel.text = "VPN"
        clearLabel.text = "Zurücksetzen"
        
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
