//
//  UpgradLumenViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 2/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class UpgradLumenNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.instance.statusBarStyle
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

class UpgradLumenViewController: UIViewController {
    #if PAID
    private let containerView = UIView()
    private let closeButton = UIButton()
    private let logoImage = UIImageView()
    private let bundlesView = UITableView()
    private let restoreButton = UIButton()
	private var promoCodeButton: UIButton?
    private let conditionButton = UIButton()
    private let arrowImage = UIImageView()
    private let conditionsLabel = UILabel()
    private let eulaButton = UIButton()
    private let privacyPolicyButton = UIButton()
    private let gradient = BrowserGradientView()
    private let notchOffset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    private var telemetrySignals: [String:String]?
    
    private let buttonAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0, weight: .medium),
        NSAttributedStringKey.foregroundColor : UIColor.white,
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    private var isConditionsHidden = true
    private var selectedProduct: LumenSubscriptionProduct?

    private var subscriptionsDataSource:StandardSubscriptionsDataSource!

	init(_ dataSource: StandardSubscriptionsDataSource) {
		subscriptionsDataSource = dataSource
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()		
        self.setupComponents()
        self.setStyles()
        self.setConstraints()
		self.navigationController?.navigationBar.isHidden = false

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
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close_UpgradeView"), style: .plain, target: self, action: #selector(closeView))
		self.navigationItem.rightBarButtonItem?.tintColor = UIColor.lumenTextBlue
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.isTranslucent = true
		
//        logoImage.image = UIImage(named: "Lumen_Logo")
//        containerView.addSubview(logoImage)
		
        switch SubscriptionController.shared.getCurrentSubscription() {
        case .limited, .trial(_):
            promoCodeButton = UIButton()
            promoCodeButton?.setTitle(NSLocalizedString("Promo Code", tableName: "Lumen", comment: "[Upgrade Flow] Promo Code Button title"), for: .normal)
            promoCodeButton?.addTarget(self, action: #selector(enterPromoCode), for: .touchUpInside)
        default:
            break
        }
        
        setupBundlesView()
        containerView.addSubview(bundlesView)
        
        
        restoreButton.addTarget(self, action: #selector(restoreSubscription), for: .touchUpInside)
        restoreButton.setTitle(NSLocalizedString("Restore Subscription", tableName: "Lumen", comment: "[Upgrade Flow] Restore Subscription button"), for: .normal)
		
		// TODO: Commented for now to fix the layout for Apple submission, but we might need to change again the UI in near future.
	
//        restoreButton.layer.borderWidth = 1.0
//        restoreButton.layer.cornerRadius = UIDevice.current.isSmallIphoneDevice() ? 15 : 20
//        containerView.addSubview(restoreButton)
		
//        conditionButton.addTarget(self, action: #selector(toggleConditions), for: .touchUpInside)
//        conditionButton.setTitle(NSLocalizedString("Conditions", tableName: "Lumen", comment: "[Upgrade Flow] Conditions button"), for: .normal)
//        containerView.addSubview(conditionButton)
		
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(toggleConditions))
//        swipeUp.direction = .up
//        conditionButton.addGestureRecognizer(swipeUp)
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(toggleConditions))
//        swipeDown.direction = .down
//        conditionButton.addGestureRecognizer(swipeDown)

        
//        arrowImage.image = UIImage(named: "Conditions_Arrow_Up")
//        containerView.addSubview(arrowImage)
		
        conditionsLabel.numberOfLines = 0
        conditionsLabel.text = NSLocalizedString("Subscriptions will be applied to your iTunes account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period‌. You can cancel anytime in your iTunes account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "[Upgrade Flow] Conditions text")
        conditionsLabel.textColor = UIColor(colorString: "BDC0CE")
        conditionsLabel.textAlignment = .center

        let eulaButtonTitle = NSMutableAttributedString(string: NSLocalizedString("End User License Agreement", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"),
                                                                 attributes: buttonAttributes)
        eulaButton.setAttributedTitle(eulaButtonTitle, for: .normal)
        eulaButton.addTarget(self, action: #selector(showEula), for: .touchUpInside)

        let privacyPolicyButtonTitle = NSMutableAttributedString(string: NSLocalizedString("Privacy Policy", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"),
                                                                 attributes: buttonAttributes)
        privacyPolicyButton.setAttributedTitle(privacyPolicyButtonTitle, for: .normal)
        privacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)

		self.view.addSubview(gradient)
        self.view.sendSubview(toBack: gradient)
    }
    
    private func setupBundlesView() {
        bundlesView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        bundlesView.separatorColor = UIColor.clear
        bundlesView.allowsSelection = false
        bundlesView.delegate = self
        bundlesView.dataSource = self
		bundlesView.tableFooterView = self.footerView()
    }
    
    private func setStyles() {
        bundlesView.backgroundColor = UIColor.clear
        
        restoreButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        restoreButton.layer.borderColor = UIColor.lumenTextBlue.cgColor
        restoreButton.clipsToBounds = true
        restoreButton.setBackgroundImage(UIImage.from(color: UIColor.cliqzBlueThreeSecondary), for: .highlighted)
		
		if let promoCodeButton = self.promoCodeButton {
			promoCodeButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
			promoCodeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
			promoCodeButton.layer.borderColor = UIColor.lumenTextBlue.cgColor
			promoCodeButton.clipsToBounds = true
			promoCodeButton.setBackgroundImage(UIImage.from(color: UIColor.cliqzBlueThreeSecondary), for: .highlighted)
		}
        conditionButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
        conditionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        conditionsLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        
        eulaButton.setTitleColor(UIColor.white, for: .normal)
        privacyPolicyButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    private func setConstraints() {
        containerView.snp.makeConstraints { (make) in
			make.edges.equalToSuperview()
        }
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bundlesView.snp.makeConstraints { (make) in
			make.top.equalTo(self.view.snp.top)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
        }

    }
    
    @objc func closeView() {
        LegacyTelemetryHelper.logPayment(action: "click", target: "close")
        self.dismiss(animated: true)
    }
    
    @objc func restoreSubscription() {
        self.telemetrySignals?["target"] = "restore"
        LegacyTelemetryHelper.logPayment(action: "click", target: self.telemetrySignals?["target"])
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
        LegacyTelemetryHelper.logPayment(action: "success", target: self.telemetrySignals?["target"])
        self.selectedProduct = nil
        self.telemetrySignals = nil
        self.dismiss(animated: true)
    }
    
    @objc func handlePurchaseErrorNotification(_ notification: Notification) {
        guard let lumenProduct = self.selectedProduct else {
            return
        }
        
        self.selectedProduct = nil
        
        LegacyTelemetryHelper.logPayment(action: "error", target: self.telemetrySignals?["target"])
        let errorDescirption = NSLocalizedString("We are sorry, but something went wrong. The payment was not successful, please try again.", tableName: "Lumen", comment: "Error message when there is failing payment transaction")
        let alertController = UIAlertController(title: "", message: errorDescirption, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", tableName: "Lumen", comment: "Retry button title in payment failing transaction alert"), style: .default) {(action) in
            self.selectedProduct = lumenProduct
            SubscriptionController.shared.buyProduct(lumenProduct.product)
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

	@objc func enterPromoCode() {
        LegacyTelemetryHelper.logPayment(action: "click", target: "code")
		var promoCodeTextField: UITextField?
		let alertView = UIAlertController(title: NSLocalizedString("Enter your promo code", tableName: "Lumen", comment: "[Upgrade flow] Promo code alert view title") , message: nil, preferredStyle: .alert)
		alertView.addTextField { (textField) in
			promoCodeTextField = textField
			print("Hi")
		}
		let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Lumen", comment: "[Upgrade flow] Cancel button title in appling promo code alert"), style: .cancel)
		alertView.addAction(cancelAction)
		let applyAction = UIAlertAction(title: NSLocalizedString("Apply", tableName: "Lumen", comment: "[Upgrade flow] Apply promo code button title in in appling promo code alert"), style: .default) { [weak self] (action) in
			let x = promoCodeTextField?.text
			self?.applyPromoCode(code: x)
		}
		alertView.addAction(applyAction)
		self.present(alertView, animated: true)
	}

	private func applyPromoCode(code: String?) {
		if let code = code, PromoCodesManager.shared.isValidPromoCode(code) {
            let promoType = PromoCodesManager.shared.getPromoType(code)
            if let productID = promoType?.promoID {
                SubscriptionController.shared.isEligible(for: productID) {[weak self] (eligible) in
                    if eligible {
                        if let promoViewController = UpgradeViewControllerFactory.promoUpgradeViewController(promoCode: code) {
                            self?.navigationController?.pushViewController(promoViewController, animated: false)
                        } else {
                            assert(false, "Design problem, please investigate")
                            self?.showInvalidPromoAlert()
                        }
                    } else {
                        self?.showNotEligible()
                    }
                }
            
            } else {
                showInvalidPromoAlert()
            }
		} else {
			showInvalidPromoAlert()
		}
	}

    private func showNotEligible() {
        LegacyTelemetryHelper.logPromoPayment(action: "show", view: "error", topic: "not_eligible")
        let alertView = UIAlertController(title: NSLocalizedString("Sorry, it seems you have used a code before", tableName: "Lumen", comment: "[Upgrade flow] Invalid Promo code alert view title") , message: nil, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: NSLocalizedString("Close", tableName: "Lumen", comment: "[Upgrade flow] Close button title on invalid promo  code alert"), style: .cancel)
        alertView.addAction(closeAction)
        self.present(alertView, animated: true)
    }
    
	private func showInvalidPromoAlert() {
        LegacyTelemetryHelper.logPromoPayment(action: "show", view: "error", topic: "invalid_code")
		let alertView = UIAlertController(title: NSLocalizedString("Sorry, this code does not seem to work", tableName: "Lumen", comment: "[Upgrade flow] Invalid Promo code alert view title") , message: nil, preferredStyle: .alert)
		let closeAction = UIAlertAction(title: NSLocalizedString("Close", tableName: "Lumen", comment: "[Upgrade flow] Close button title on invalid promo  code alert"), style: .cancel)
		alertView.addAction(closeAction)
		self.present(alertView, animated: true)
	}

    #endif
}

#if PAID
extension UpgradLumenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return subscriptionsDataSource.subscriptionsCount()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return subscriptionsDataSource.subscriptionHeight(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! SubscriptionTableViewCell
        let subscriptionInfo = subscriptionsDataSource.subscriptionInfo(indexPath: indexPath)
		cell.subscriptionInfo = subscriptionInfo
        cell.buyButtonHandler = { [weak self] subscriptionProduct in
            SubscriptionController.shared.buyProduct(subscriptionProduct.product)
            self?.selectedProduct = subscriptionProduct
            self?.telemetrySignals = subscriptionInfo?.telemetrySignals
            LegacyTelemetryHelper.logPayment(action: "click", target: self?.telemetrySignals?["target"])
        }
        return cell
    }

	fileprivate func footerView() -> UIView {
		// TODO: if we keep this solutin the height should be calculated
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 210))
		footerView.addSubview(self.restoreButton)
		footerView.addSubview(self.conditionsLabel)
		footerView.addSubview(self.eulaButton)
		footerView.addSubview(self.privacyPolicyButton)
		if let promoCodeButton = self.promoCodeButton{
			footerView.addSubview(promoCodeButton)
			promoCodeButton.snp.makeConstraints { (make) in
				make.right.equalToSuperview().inset(30.0)
				make.top.equalToSuperview()
				make.height.equalTo(30.0)
			}
		}
		restoreButton.snp.makeConstraints { (make) in
			make.left.equalToSuperview().inset(30.0)
			make.top.equalToSuperview()
			make.height.equalTo(30.0)
		}
		conditionsLabel.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(15.0)
			make.top.equalTo(restoreButton.snp.bottom).offset(3)
		}
		eulaButton.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(conditionsLabel.snp.bottom).offset(5)
		}
		privacyPolicyButton.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(eulaButton.snp.bottom).offset(5)
		}
		return footerView
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
