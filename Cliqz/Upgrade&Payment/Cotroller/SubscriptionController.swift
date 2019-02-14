//
//  SubscriptionController.swift
//  Cliqzy
//
//  Created by Mahmoud Adam on 1/3/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift

public class SubscriptionController {
    public static let shared = SubscriptionController()
    
    //MARK:- Private variables
    private let storeService: IAPService
    private let TrialPeriod: TimeInterval = 14 * 24 * 60 * 60
    private let purchasedProductIdentifierKey = "Lumen.PurchasedProductIdentifier"
    private let expirationDateKey = "Lumen.ExpirationDate"
    private let trialExpiredViewLastDismissedKey = "Lumen.TrialExpiredView.lastDismissed"
    private let disposeBag = DisposeBag()
    var availableSubscriptions = [PremiumType : SKProduct]()
    
    //MARK:- initialization
    init() {
        
        storeService = RevenueCatService()
        storeService.asObserver().subscribe(onNext: { [weak self] (lumenPurchaseInfo) in
            guard let self = self else { return }
            self.savePurchasedProduct(productIdentifier: lumenPurchaseInfo.productIdentifier)
            self.saveExpirationDate(lumenPurchaseInfo.expirationDate)
            self.updateUltimateProtectionStatus()
        }).disposed(by: disposeBag)
        
        if getExpirationDate() == nil {
            saveExpirationDate(Date().addingTimeInterval(TrialPeriod))
        }
        self.updateUltimateProtectionStatus()
    }
    
    private func saveExpirationDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: expirationDateKey)
    }
    
    private func getExpirationDate() -> Date? {
        return UserDefaults.standard.object(forKey: expirationDateKey) as? Date
    }
    
    private func savePurchasedProduct(productIdentifier: String) {
        UserDefaults.standard.set(productIdentifier, forKey: purchasedProductIdentifierKey)
    }
    
    private func updateUltimateProtectionStatus() {
        #if PAID
        switch getCurrentSubscription() {
        case .limited:
            UserPreferences.instance.isProtectionOn = false
        default:
            return
        }
        #endif
    }
    
    //MARK:- Subscriptions
    public func requestProducts() {
        storeService.requestProducts {[weak self] (success, products) in
            guard let self = self, let products = products, success else { return }
            self.availableSubscriptions.removeAll()
            for product in products {
                if let premiumType = PremiumType.init(rawValue: product.productIdentifier) {
                    self.availableSubscriptions[premiumType] = product
                }
            }
        }
    }
    
    public func buyProduct(_ premiumType: PremiumType) {
        if let product = availableSubscriptions[premiumType] {
            storeService.buyProduct(product)
        }
    }
    
    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    public func restorePurchases() {
        storeService.restorePurchases()
    }
    
    public func getSubscriptionUserId() -> String? {
        return storeService.getSubscriptionUserId()
    }
    
    public func isVPNEnabled() -> Bool {
        let currentSubscription = getCurrentSubscription()
        switch currentSubscription {
        case .trial(_):
            return true
        case .premium(let premiumType, _):
            return premiumType.hasVPN()
        default:
            return false
        }
    }

    public func getCurrentSubscription() -> LumenSubscriptionType {
        
        if let expirationDate = getExpirationDate(), Date().timeIntervalSince(expirationDate) < 0 {
            if let purchasedProductIdentifier = UserDefaults.standard.string(forKey: purchasedProductIdentifierKey),
                let permiumType = PremiumType.init(rawValue: purchasedProductIdentifier) {
                
                return .premium(permiumType, expirationDate)
            }
            return .trial(expirationDate)
            
        }
        return .limited
    }
    
    public func shouldShowTrialExpiredView() -> Bool {
        switch getCurrentSubscription() {
        case .limited:
            guard let lastDismissedDate = UserDefaults.standard.object(forKey: trialExpiredViewLastDismissedKey) as? Date,
                let daysCount = lastDismissedDate.daysUntil(Date()) else {
                return true
            }
            return daysCount > 7
        default:
            return false
        }
    }
    
    public func trialExpiredViewDisplayed() {
        UserDefaults.standard.set(nil, forKey: trialExpiredViewLastDismissedKey)
    }
    
    public func trialExpiredViewDismissed() {
        UserDefaults.standard.set(Date(), forKey: trialExpiredViewLastDismissedKey)
    }
}

