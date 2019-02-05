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
    
    private let buttonAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0, weight: .medium),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    private var isConditionsHidden = true
    private let premiumTypes: [PremiumType] = [.Pro, .Plus, .Basic]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupComponents()
        self.setStyles()
        self.setConstraints()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.instance.statusBarStyle
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
        restoreButton.layer.cornerRadius = 20
        containerView.addSubview(restoreButton)
        
        conditionButton.addTarget(self, action: #selector(toggleConditions), for: .touchUpInside)
        conditionButton.setTitle(NSLocalizedString("Conditions", tableName: "Lumen", comment: "[Upgrade Flow] Conditions button"), for: .normal)
        containerView.addSubview(conditionButton)
        
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
        bundlesView.separatorColor = UIColor(colorString: "BDC0CE")
        bundlesView.allowsSelection = false
        bundlesView.isScrollEnabled = false
        bundlesView.delegate = self
        bundlesView.dataSource = self
    }
    
    private func setStyles() {
        bundlesView.backgroundColor = UIColor.clear
        
        restoreButton.setTitleColor(UIColor.lumenBrightBlue, for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        restoreButton.layer.borderColor = UIColor.lumenBrightBlue.cgColor
        
        conditionButton.setTitleColor(UIColor.lumenBrightBlue, for: .normal)
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
            make.top.equalToSuperview().inset(10.0)
            make.centerX.equalToSuperview()
        }
        
        
        bundlesView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImage.snp.bottom).offset(10.0)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(370.0)
        }
        
        restoreButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(conditionButton.snp.top).offset(-10.0)
            make.width.equalTo(230.0)
            make.height.equalTo(40.0)
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
        self.dismiss(animated: true)
    }
    
    @objc func restoreSubscription() {
        
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
    
    private func navigateToUrl(_ urlString: String) {
        if let appDel = UIApplication.shared.delegate as? AppDelegate,
            let browserViewController = appDel.browserViewController,
            let url = URL(string: urlString)
        {
            browserViewController.settingsOpenURLInNewTab(url)
        }
    }
    
    @objc func toggleConditions() {
        
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


extension UpgradLumenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.premiumTypes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! SubscriptionTableViewCell
        cell.premiumType = self.premiumTypes[indexPath.row]
        cell.buyButtonHandler = { premiumType in
            SubscriptionController.shared.buyProduct(premiumType)
        }
        
        return cell
    }
    
}
