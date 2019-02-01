//
//  RevenueCatService.swift
//  Cliqzy
//
//  Created by Mahmoud Adam on 1/14/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit
import Purchases
import StoreKit
import RxSwift

class RevenueCatService: NSObject, IAPService {
    private var purchases: Purchases?
    
    let observable = PublishSubject<LumenPurchaseInfo>()
    
    override init() {
        super.init()
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "RevenuecatAPIKey") as? String, !apiKey.isEmpty else {
            print("RevenuecatAPIKey is not available in Info.plist")
            return
        }
        purchases = Purchases.configure(withAPIKey: apiKey)
        purchases?.delegate = self
    }
    
    public func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler) {
        guard let purchases = self.purchases else {
            completionHandler(false, [SKProduct]())
            return
        }
		purchases.entitlements { (entitlements, error) in
			guard let entitlements = entitlements else {
				completionHandler(false, nil)
				return
			}
			print("Loaded list of products...")
			var products = [SKProduct]()
			for entitlement in entitlements.values {
				for offering in entitlement.offerings.values {
					if let product = offering.activeProduct {
						products.append(product)
					}
				}
			}
			completionHandler(true, products)
		}
        
//        purchases.entitlements({ (entitlements) in
//            guard let entitlements = entitlements else {
//                completionHandler(false, nil)
//                return
//            }
//            print("Loaded list of products...")
//            var products = [SKProduct]()
//            for entitlement in entitlements.values {
//                for offering in entitlement.offerings.values {
//                    if let product = offering.activeProduct {
//                        products.append(product)
//                    }
//                }
//            }
//            completionHandler(true, products)
//        })
    }
    
    
    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
		purchases?.makePurchase(product, { (translation, info, error) in
			// TODO:
		})
//        purchases?.makePurchase(product)
    }
    
    
    public func restorePurchases() {
		purchases?.restoreTransactions({ (info, error) in
			// TODO:
		})
//        purchases?.restoreTransactionsForAppStoreAccount()
    }
    
    public func getSubscriptionUserId() -> String? {
        return purchases?.appUserID
    }
    
    public func asObserver() -> PublishSubject<LumenPurchaseInfo> {
        return observable.asObserver()
    }
}

extension RevenueCatService: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdatedPurchaserInfo purchaserInfo: PurchaserInfo) {
        print("receivedUpdatedPurchaserInfo: \(purchaserInfo.activeSubscriptions)")
        processPurchaseInfo(purchaserInfo)
    }
    
    func purchases(_ purchases: Purchases, failedToUpdatePurchaserInfoWithError error: Error) {
        print("failedToUpdatePurchaserInfoWithError: \(error.localizedDescription)")
    }
    
    func purchases(_ purchases: Purchases, completedTransaction transaction: SKPaymentTransaction, withUpdatedInfo purchaserInfo: PurchaserInfo) {
        print("completedTransaction")
        processPurchaseInfo(purchaserInfo)
    }
    
    func purchases(_ purchases: Purchases, failedTransaction transaction: SKPaymentTransaction, withReason failureReason: Error) {
        print("failedTransaction: \(failureReason.localizedDescription)")
    }
    
    func purchases(_ purchases: Purchases, restoredTransactionsWith purchaserInfo: PurchaserInfo) {
        print("restoredTransactionsWith")
        processPurchaseInfo(purchaserInfo)
    }
    
    func purchases(_ purchases: Purchases, failedToRestoreTransactionsWithError error: Error) {
        print("failedToRestoreTransactionsWithError: \(error.localizedDescription)")
    }
    
    private func processPurchaseInfo(_ purchaserInfo: PurchaserInfo) {
        guard let identifier = purchaserInfo.activeSubscriptions.first,
            let expirationDate = purchaserInfo.expirationDate(forProductIdentifier: identifier) else {
            return
        }
        let lumenPurchaseInfo = LumenPurchaseInfo(productIdentifier: identifier, expirationDate: expirationDate)
        print("processPurchaseInfo -> identifier: \(identifier), expirationDate: \(expirationDate)")
        observable.onNext(lumenPurchaseInfo)
    }
    
    
}
