//
//  BaseUpgradeViewController.swift
//  Client
//
//  Created by Pavel Kirakosyan on 11.06.19.
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
class BaseUpgradeViewController: UIViewController {
    #if PAID
    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let dataSource: SubscriptionDataSource
    
    var selectedProduct: LumenSubscriptionProduct?
    let gradient = BrowserGradientView()
    
    init(_ dataSource: SubscriptionDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseSuccessNotification(_:)),
                                               name: .ProductPurchaseSuccessNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseErrorNotification(_:)),
                                               name: .ProductPurchaseErrorNotification,
                                               object: nil)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func handlePurchaseSuccessNotification(_ notification: Notification) {
        self.selectedProduct = nil
        self.dismiss(animated: true)
    }
    
    @objc func handlePurchaseErrorNotification(_ notification: Notification) {
        guard let lumenProduct = self.selectedProduct else {
            return
        }
        self.selectedProduct = nil
        let telemetrySignals = self.dataSource.telemeterySignals(product: lumenProduct)
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
    
    @objc func closeView() {
        LegacyTelemetryHelper.logPayment(action: "click", target: "close")
        self.dismiss(animated: true)
    }

    func fetchProducts() {
        self.startLoadingAnimation()
        self.dataSource.fetchProducts {[weak self] (success) in
            if success {
                self?.reloadData()
            } else {
                self?.showProductsRetrievalFailedAlert()
            }
            self?.stopLoadingAnimation()
        }
    }
    
    func reloadData() {
        assert(false, "Subclasses must reimplement")
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

    private func startLoadingAnimation() {
        self.loadingView.startAnimating()
    }
    
    private func stopLoadingAnimation() {
        self.loadingView.stopAnimating()
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
    #endif
}
