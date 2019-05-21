//
//  RevenueCatService.swift
//  Cliqzy
//
//  Created by Mahmoud Adam on 1/14/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit
import StoreKit
import RxSwift
import Purchases
import Shared

class RevenueCatService: NSObject, IAPService {
    private var purchases: Purchases?
    
    let observable = PublishSubject<LumenPurchaseInfo>()
    
    override init() {
        super.init()
        guard let apiKey = APIKeys.revenuecatAPI, !apiKey.isEmpty else {
            print("RevenuecatAPIKey is not available in Info.plist")
            return
        }
        purchases = Purchases.configure(withAPIKey: apiKey)
        purchases?.delegate = self
    }
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        guard let purchases = self.purchases else {
            completionHandler(false, [(product: SKProduct, group: String)]())
            return
        }
		purchases.entitlements { (entitlements, error) in
			guard let entitlements = entitlements else {
				completionHandler(false, nil)
				return
			}
			print("Loaded list of products...")
			var products = [(product: SKProduct, group: String)]()
			for (key,value) in entitlements {
				for offering in value.offerings.values {
					if let product = offering.activeProduct {
						products.append((product, key))
					}
				}
			}
			completionHandler(true, products)
		}
    }
    
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
		purchases?.makePurchase(product, { (transaction, purchaserInfo, error) in
            if let error = error as? SKError, error.code != .paymentCancelled {
                NotificationCenter.default.post(name: .ProductPurchaseErrorNotification, object: error.localizedDescription)
            } else if let purchaserInfo = purchaserInfo {
                self.processPurchaseInfo(purchaserInfo)
            }
		})
    }
    
    public func restorePurchases() {
		purchases?.restoreTransactions({ (purchaserInfo, error) in
            if let error = error as? SKError, error.code != .paymentCancelled {
                NotificationCenter.default.post(name: .ProductPurchaseErrorNotification, object: error.localizedDescription)
            } else if let purchaserInfo = purchaserInfo {
                self.processPurchaseInfo(purchaserInfo)
            }
		})
    }
    
    public func getSubscriptionUserId() -> String? {
        return purchases?.appUserID
    }
    
    public func asObserver() -> PublishSubject<LumenPurchaseInfo> {
        return observable.asObserver()
    }
}

extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, didReceiveUpdated purchaserInfo: PurchaserInfo) {
        self.processPurchaseInfo(purchaserInfo)
    }
    
    private func processPurchaseInfo(_ purchaserInfo: PurchaserInfo) {
        guard let identifier = getLastestIdentifier(purchaserInfo),
            let expirationDate = purchaserInfo.expirationDate(forProductIdentifier: identifier) else {
            return
        }
        let lumenPurchaseInfo = LumenPurchaseInfo(productIdentifier: identifier, expirationDate: expirationDate)
        print("processPurchaseInfo -> identifier: \(identifier), expirationDate: \(expirationDate)")
        observable.onNext(lumenPurchaseInfo)
        NotificationCenter.default.post(name: .ProductPurchaseSuccessNotification, object: identifier)
    }
    
    fileprivate func getLastestIdentifier(_ purchaserInfo: PurchaserInfo) -> String? {
        guard var latestIdentifier = purchaserInfo.activeSubscriptions.first,
            var latestExpirationDate = purchaserInfo.expirationDate(forProductIdentifier:latestIdentifier) else {
            return nil
        }
        
        for identifier in purchaserInfo.activeSubscriptions {
            if let expirationDate = purchaserInfo.expirationDate(forProductIdentifier:identifier),
                expirationDate > latestExpirationDate {
                latestIdentifier = identifier
                latestExpirationDate = expirationDate
            }
        }
        return latestIdentifier
    }
    
}
