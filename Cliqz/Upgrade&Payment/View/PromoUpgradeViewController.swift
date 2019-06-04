//
//  PromoUpgradeViewController.swift
//  Client
//
//  Created by Sahakyan on 5/15/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

#if PAID

class PromoUpgradeViewController: UIViewController {
	
	private var closeButton: UIButton?

	private let promoValidityLabel = UILabel()
	private let promoCodeLabel = UILabel()

	private let subscriptionsTableView = UITableView()
	private let conditionsLabel = UILabel()
	private let eulaButton = UIButton()
	private let privacyPolicyButton = UIButton()
	private let dataSource: PromoSubscriptionsDataSource
    private var selectedProduct: LumenSubscriptionProduct?
    private let gradient = BrowserGradientView()
    private let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
	init(_ dataSource: PromoSubscriptionsDataSource) {
		self.dataSource = dataSource
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.navigationBar.tintColor = UIColor.lumenTextBlue
		if self.navigationController == nil {
			showCloseButton()
		}
		setupComponents()
		setConstraints()
        
        // TODO: code duplication, need create a superclass for Updgrade conroller and move all this logic
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseSuccessNotification(_:)),
                                               name: .ProductPurchaseSuccessNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseErrorNotification(_:)),
                                               name: .ProductPurchaseErrorNotification,
                                               object: nil)
        
        let telemetryView = self.dataSource.telemeterySignals()["view"]
        LegacyTelemetryHelper.logPromoPayment(action: "show", view: telemetryView)
        self.fetchProducts()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
	}
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.instance.statusBarStyle
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc func handlePurchaseSuccessNotification(_ notification: Notification) {
        let telemetrySignals = self.dataSource.telemeterySignals()
        LegacyTelemetryHelper.logPromoPayment(action: "success", target: telemetrySignals["target"], view: telemetrySignals["view"])
        self.selectedProduct = nil
        self.dismiss(animated: true)
    }
    
    @objc func handlePurchaseErrorNotification(_ notification: Notification) {
        guard let lumenProduct = self.selectedProduct else {
            return
        }
        self.selectedProduct = nil
        let telemetrySignals = self.dataSource.telemeterySignals()
        LegacyTelemetryHelper.logPromoPayment(action: "error", target: telemetrySignals["target"], view: telemetrySignals["view"])
        let errorDescirption = NSLocalizedString("We are sorry, but something went wrong. The payment was not successful, please try again.", tableName: "Lumen", comment: "Error message when there is failing payment transaction")
        let alertController = UIAlertController(title: "", message: errorDescirption, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", tableName: "Lumen", comment: "Retry button title in payment failing transaction alert"), style: .default) {(action) in
            self.selectedProduct = lumenProduct
            SubscriptionController.shared.buyProduct(lumenProduct.product)
        })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", tableName: "Lumen", comment: "Cancel button title in payment failing transaction alert"), style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func fetchProducts() {
        self.startLoadingAnimation()
        self.dataSource.fetchProducts { (success) in
            if success {
                self.reloadData()
            } else {
                self.showProductsRetrievalFailedAlert()
            }
            self.stopLoadingAnimation()
        }
    }
    
    private func reloadData() {
        self.subscriptionsTableView.reloadData()
        self.conditionsLabel.text = self.dataSource.getConditionText()
        self.promoCodeLabel.text = self.dataSource.promoText()
    }
    
    private func showProductsRetrievalFailedAlert() {
        let errorDescirption = NSLocalizedString("Sorry, Lumen cannot connect to the Internet.", tableName: "Lumen", comment: "Error when can't get list of available subscriptions")
        let alertController = UIAlertController(title: "", message: errorDescirption, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", tableName: "Lumen", comment: "Retry button title in payment failing transaction alert"), style: .default) {[weak self] (action) in
            self?.fetchProducts()
        })
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Close", tableName: "Lumen", comment: "Closing subscription screen"), style: .default, handler: {[weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }

	private func setupComponents() {
		self.promoValidityLabel.text = NSLocalizedString("This code is valid", tableName: "Lumen", comment: "[Upgrade flow] PromoCode validity text on Promo subsicription view.")
		self.promoValidityLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .medium)
		self.promoValidityLabel.textColor = UIColor(colorString: "9FA1AE")
		self.promoValidityLabel.textAlignment = .center
		self.view.addSubview(self.promoValidityLabel)

        self.promoCodeLabel.text = self.dataSource.promoText()
		self.promoCodeLabel.textAlignment = .center
		self.promoCodeLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
		self.promoCodeLabel.textColor = UIColor(colorString: "D9A8B5")
		self.view.addSubview(self.promoCodeLabel)

		subscriptionsTableView.backgroundColor = UIColor.clear
		subscriptionsTableView.register(SubscriptionTableViewCell.self, forCellReuseIdentifier: "ProductCell")
		subscriptionsTableView.separatorColor = UIColor.clear
		subscriptionsTableView.allowsSelection = false
		subscriptionsTableView.delegate = self
		subscriptionsTableView.dataSource = self
		subscriptionsTableView.tableFooterView = self.footerView()
		self.view.addSubview(subscriptionsTableView)

		conditionsLabel.numberOfLines = 0
		conditionsLabel.text = self.dataSource.getConditionText()
		conditionsLabel.textColor = UIColor(colorString: "BDC0CE")

		conditionsLabel.textAlignment = .center
		conditionsLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .regular)

		let buttonAttributes : [NSAttributedStringKey: Any] = [
			NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0, weight: .medium),
			NSAttributedStringKey.foregroundColor : UIColor.white,
			NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
		let eulaButtonTitle = NSMutableAttributedString(string: NSLocalizedString("End User License Agreement", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"), attributes: buttonAttributes)
		eulaButton.setTitleColor(UIColor.white, for: .normal)

		eulaButton.setAttributedTitle(eulaButtonTitle, for: .normal)
		eulaButton.addTarget(self, action: #selector(showEula), for: .touchUpInside)
		
		let privacyPolicyButtonTitle = NSMutableAttributedString(string: NSLocalizedString("Privacy Policy", tableName: "Lumen", comment: "[Upgrade Flow] Privacy Policy button"), attributes: buttonAttributes)
		privacyPolicyButton.setTitleColor(UIColor.white, for: .normal)
		privacyPolicyButton.setAttributedTitle(privacyPolicyButtonTitle, for: .normal)
		privacyPolicyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)
        
        self.view.addSubview(gradient)
        self.view.sendSubview(toBack: gradient)
        self.view.addSubview(self.loadingView)
	}

	private func setConstraints() {
		if let closeButton = self.closeButton {
			closeButton.snp.makeConstraints { (make) in
				make.trailing.equalToSuperview().inset(10.0)
				make.top.equalTo(self.view.safeArea.top).offset(10.0)
				make.width.equalTo(44.0)
				make.height.equalTo(44.0)
			}
		}
        
        gradient.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

		promoValidityLabel.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview().offset(100)
			make.height.equalTo(20)
		}
		promoCodeLabel.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.top.equalTo(promoValidityLabel.snp.bottom)
			make.height.equalTo(30)
		}
		subscriptionsTableView.snp.makeConstraints { (make) in
			make.top.equalTo(self.promoCodeLabel.snp.bottom).offset(20)
			make.leading.trailing.equalToSuperview()
			make.bottom.equalToSuperview()
		}
        
        loadingView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
	}
    
    private func startLoadingAnimation() {
        self.loadingView.startAnimating()
    }
    
    private func stopLoadingAnimation() {
        self.loadingView.stopAnimating()
    }

	private func showCloseButton() {
		self.closeButton = UIButton(type: .custom)
		self.closeButton?.setImage(UIImage(named: "Close_UpgradeView"), for: .normal)
		self.view.addSubview(self.closeButton!)
		self.closeButton?.addTarget(self, action: #selector(closeView), for: .touchUpInside)
	}

	@objc func closeView() {
		self.dismiss(animated: true, completion: nil)
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
}

extension PromoUpgradeViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.subscriptionsCount()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return self.dataSource.subscriptionHeight(indexPath: indexPath)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! SubscriptionTableViewCell
		let subscriptionInfo = self.dataSource.subscriptionInfo(indexPath: indexPath)
		cell.subscriptionInfo = subscriptionInfo
        cell.buyButtonHandler = {[weak self] subscriptionProduct in
            self?.selectedProduct = subscriptionProduct
            SubscriptionController.shared.buyProduct(subscriptionProduct.product)
            LegacyTelemetryHelper.logPromoPayment(action: "click", target: subscriptionInfo?.telemetrySignals["target"], view: subscriptionInfo?.telemetrySignals["view"])
        }
		return cell
	}
	
	fileprivate func footerView() -> UIView {
		// TODO: if we keep this solutin the height should be calculated
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 210))
		footerView.addSubview(self.conditionsLabel)
		footerView.addSubview(self.eulaButton)
		footerView.addSubview(self.privacyPolicyButton)
		
		conditionsLabel.snp.makeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.leading.trailing.equalToSuperview().inset(15.0)
			make.top.equalToSuperview().offset(20)
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
	
}

#endif
