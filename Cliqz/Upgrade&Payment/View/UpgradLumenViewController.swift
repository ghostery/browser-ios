//
//  UpgradLumenViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 2/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class UpgradLumenViewController: UIViewController {
    #if PAID
    private let containerView = UIView()
    private let closeButton = UIButton()
    private let logoImage = UIImageView()
    private let bundlesView = UITableView()
    private let restoreButton = UIButton()
    private let conditionButton = UIButton()
    private let arrowImage = UIImageView()
    private let conditionsLabel = UILabel()
    private let eulaButton = UIButton()
    private let privacyPolicyButton = UIButton()
    private let gradient = BrowserGradientView()
    private let notchOffset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    private var telemetryTarget: String?
    
    private let buttonAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0, weight: .medium),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    private var isConditionsHidden = true
    private let premiumTypes: [PremiumType] = SubscriptionController.shared.hasBasicSubscription() ? [.Pro, .Basic] : [.Plus, .Pro, .Basic]
    private var lastShosenPremiumType: PremiumType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupComponents()
        self.setStyles()
        self.setConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseSuccessNotification(_:)),
                                               name: .ProductPurchaseSuccessNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseErrorNotification(_:)),
                                               name: .ProductPurchaseErrorNotification,
                                               object: nil)
        
        LegacyTelemetryHelper.logPayment(action: "show")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.instance.statusBarStyle
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func setupComponents() {
        self.view.addSubview(containerView)
        
        closeButton.setImage(UIImage(named: "Close_UpgradeView"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        containerView.addSubview(closeButton)
        
        logoImage.image = UIImage(named: "Lumen_Logo")
        containerView.addSubview(logoImage)
        
        setupBundlesView()
        containerView.addSubview(bundlesView)
        
        
        restoreButton.addTarget(self, action: #selector(restoreSubscription), for: .touchUpInside)
        restoreButton.setTitle(NSLocalizedString("Restore Subscription", tableName: "Lumen", comment: "[Upgrade Flow] Restore Subscription button"), for: .normal)
        restoreButton.layer.borderWidth = 1.0
        restoreButton.layer.cornerRadius = UIDevice.current.isSmallIphoneDevice() ? 15 : 20
        containerView.addSubview(restoreButton)
        
        conditionButton.addTarget(self, action: #selector(toggleConditions), for: .touchUpInside)
        conditionButton.setTitle(NSLocalizedString("Conditions", tableName: "Lumen", comment: "[Upgrade Flow] Conditions button"), for: .normal)
        containerView.addSubview(conditionButton)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(toggleConditions))
        swipeUp.direction = .up
        conditionButton.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(toggleConditions))
        swipeDown.direction = .down
        conditionButton.addGestureRecognizer(swipeDown)

        
        arrowImage.image = UIImage(named: "Conditions_Arrow_Up")
        containerView.addSubview(arrowImage)
        
        
        conditionsLabel.numberOfLines = 0
        conditionsLabel.text = NSLocalizedString("Subscriptions will be applied to your iTunes account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period‌. You can cancel anytime in your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "[Upgrade Flow] Conditions text")
        conditionsLabel.textColor = UIColor(colorString: "BDC0CE")
        conditionsLabel.textAlignment = .center
        containerView.addSubview(conditionsLabel)

        
        let eulaButtonTitle = NSMutableAttributedString(string: NSLocalizedString("End User License Agreement", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"),
                                                                 attributes: buttonAttributes)
        eulaButton.setAttributedTitle(eulaButtonTitle, for: .normal)
        eulaButton.addTarget(self, action: #selector(showEula), for: .touchUpInside)
        containerView.addSubview(eulaButton)
        

        let privacyPolicyButtonTitle = NSMutableAttributedString(string: NSLocalizedString("Privacy Policy", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"),
                                                                 attributes: buttonAttributes)
        privacyPolicyButton.setAttributedTitle(privacyPolicyButtonTitle, for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        containerView.addSubview(privacyPolicyButton)
        
        view.addSubview(gradient)
        view.sendSubview(toBack: gradient)
    }
    
    private func setupBundlesView() {
        bundlesView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        bundlesView.separatorColor = UIColor.clear
        bundlesView.allowsSelection = false
        bundlesView.isScrollEnabled = false
        bundlesView.delegate = self
        bundlesView.dataSource = self
    }
    
    private func setStyles() {
        bundlesView.backgroundColor = UIColor.clear
        
        restoreButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        restoreButton.layer.borderColor = UIColor.lumenTextBlue.cgColor
        
        conditionButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
        conditionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        conditionsLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        eulaButton.setTitleColor(UIColor.white, for: .normal)
        privacyPolicyButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func setConstraints() {
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeArea.top)
            make.bottom.equalTo(self.view.safeArea.bottom)
            make.leading.equalTo(self.view.safeArea.leading)
            make.trailing.equalTo(self.view.safeArea.trailing)
        }
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview().inset(10.0)
            make.width.equalTo(44.0)
            make.height.equalTo(44.0)
        }
        
        logoImage.snp.makeConstraints { (make) in
            if UIDevice.current.isSmallIphoneDevice() {
                make.top.equalToSuperview()
            } else {
                make.top.equalToSuperview().inset(10.0)
            }
            make.centerX.equalToSuperview()
        }
        
        
        bundlesView.snp.makeConstraints { (make) in
            if UIDevice.current.isSmallIphoneDevice() {
                make.top.equalTo(logoImage.snp.bottom)
            } else {
                make.top.equalTo(logoImage.snp.bottom).offset(10.0)
            }
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(415.0)
        }
        
        restoreButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            
            if UIDevice.current.isSmallIphoneDevice() {
                make.bottom.equalTo(conditionButton.snp.top)
                make.width.equalTo(200.0)
                make.height.equalTo(30.0)
            } else {
                make.bottom.equalTo(conditionButton.snp.top).offset(-10.0)
                make.width.equalTo(230.0)
                make.height.equalTo(40.0)
            }
            
        }
        
        conditionButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(arrowImage.snp.top)
            make.height.equalTo(25.0)
        }
        
        arrowImage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(5.0)
            make.width.equalTo(45.0)
            make.height.equalTo(9.0)
        }
        
        conditionsLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(15.0)
            make.top.equalTo(arrowImage.snp.bottom).offset(10.0 + notchOffset)
        }
        
        eulaButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(conditionsLabel.snp.bottom).offset(5.0)
        }
        
        privacyPolicyButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(eulaButton.snp.bottom).offset(5)
        }
    }
    
    @objc func closeView() {
        LegacyTelemetryHelper.logPayment(action: "click", target: "close")
        self.dismiss(animated: true)
    }
    
    @objc func restoreSubscription() {
        telemetryTarget = "restore"
        LegacyTelemetryHelper.logPayment(action: "click", target: telemetryTarget)
        SubscriptionController.shared.restorePurchases()
    }
    
    @objc func showEula() {
        self.dismiss(animated: false) {[weak self] in
            self?.navigateToUrl("https://lumenbrowser.com/lumen_eula.html")
        }
    }
    
    @objc func showPrivacyPolicy() {
        self.dismiss(animated: false) {[weak self] in
            self?.navigateToUrl("https://lumenbrowser.com/dse.html")
        }
    }
    
    @objc func handlePurchaseSuccessNotification(_ notification: Notification) {
        LegacyTelemetryHelper.logPayment(action: "success", target: telemetryTarget)
        self.dismiss(animated: true)
    }
    
    @objc func handlePurchaseErrorNotification(_ notification: Notification) {
        LegacyTelemetryHelper.logPayment(action: "error", target: telemetryTarget)
        let errorDescirption = NSLocalizedString("We are sorry, but something went wrong. The payment was not successful, please try again.", tableName: "Lumen", comment: "Error message when there is failing payment transaction")
        let alertController = UIAlertController(title: "", message: errorDescirption, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", tableName: "Lumen", comment: "Retry button title in payment failing transaction alert"), style: .default) {[weak self] (action) in
            if let premiumType = self?.lastShosenPremiumType {
                SubscriptionController.shared.buyProduct(premiumType)
            }
        })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Lumen", comment: "Cancel button title in payment failing transaction alert"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToUrl(_ urlString: String) {
        if let appDel = UIApplication.shared.delegate as? AppDelegate,
            let browserViewController = appDel.browserViewController,
            let url = URL(string: urlString)
        {
            browserViewController.settingsOpenURLInNewTab(url)
        }
    }
    
    @objc func toggleConditions() {
        LegacyTelemetryHelper.logPayment(action: "click", target: "conditions")
        if isConditionsHidden {
            UIView.animate(withDuration: 0.5) {
                let conditionsOffset = -1.0 * self.getContidionOffet()
                self.arrowImage.image = UIImage(named: "Conditions_Arrow_Down")
                self.containerView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.view.safeArea.top).offset(conditionsOffset)
                    make.bottom.equalTo(self.view.safeArea.bottom)
                    make.leading.equalTo(self.view.safeArea.leading)
                    make.trailing.equalTo(self.view.safeArea.trailing)
                }
                self.arrowImage.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview().offset(conditionsOffset)
                    make.width.equalTo(45)
                    make.height.equalTo(9)
                }
                
                self.conditionsLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(15.0)
                    make.top.equalTo(self.arrowImage.snp.bottom).offset(10.0)
                }
            }
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.arrowImage.image = UIImage(named: "Conditions_Arrow_Up")
                self.containerView.snp.remakeConstraints { (make) in
                    make.top.equalTo(self.view.safeArea.top)
                    make.bottom.equalTo(self.view.safeArea.bottom)
                    make.leading.equalTo(self.view.safeArea.leading)
                    make.trailing.equalTo(self.view.safeArea.trailing)
                }
                self.arrowImage.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.bottom.equalToSuperview().inset(5.0)
                    make.width.equalTo(45.0)
                    make.height.equalTo(9.0)
                }
                
                self.conditionsLabel.snp.remakeConstraints { (make) in
                    make.centerX.equalToSuperview()
                    make.leading.trailing.equalToSuperview().inset(15.0)
                    make.top.equalTo(self.arrowImage.snp.bottom).offset(10.0 + self.notchOffset)
                }
            }
        }
        
        isConditionsHidden = !isConditionsHidden
    }
    
    func getContidionOffet() -> CGFloat {
        return conditionsLabel.bounds.size.height
                + eulaButton.bounds.size.height
                + privacyPolicyButton.bounds.size.height
                + 35.0
    }
    #endif
}

#if PAID
extension UpgradLumenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.premiumTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let premiumType = self.premiumTypes[indexPath.row]
        if premiumType == .Pro {
            return 150
        }
        return 135.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! SubscriptionTableViewCell
        cell.premiumType = self.premiumTypes[indexPath.row]
        cell.buyButtonHandler = { [weak self] premiumType in
            SubscriptionController.shared.buyProduct(premiumType)
            self?.lastShosenPremiumType = premiumType
            self?.telemetryTarget = premiumType.getTelemeteryTarget()
            LegacyTelemetryHelper.logPayment(action: "click", target: self?.telemetryTarget)
        }
        return cell
    }

	private func subscriptionsComingSoon() {
		let title = NSLocalizedString("Coming Soon!", tableName: "Lumen", comment: "Temporary message title instead of Subscriptions")
		let message = NSLocalizedString("Subscriptions will be available soon.", tableName: "Lumen", comment: "Temporary message instead of Subscriptions")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: NSLocalizedString("Close", tableName: "Lumen", comment: "Cancel button title in payment failing transaction alert"), style: .default, handler: nil))
		self.present(alertController, animated: true, completion: nil)
	}
}

#endif
