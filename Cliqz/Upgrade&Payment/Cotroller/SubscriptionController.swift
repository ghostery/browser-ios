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
    private let TrialPeriod: Int = 7
    private let purchasedProductIdentifierKey = "Lumen.PurchasedProductIdentifier"
    private let expirationDateKey = "Lumen.ExpirationDate"
    private let trialRemainingDaysKey = "Lumen.TrialRemainingDays"
    private let trialExpiredViewLastDismissedKey = "Lumen.TrialExpiredView.lastDismissed"
    private let disposeBag = DisposeBag()
    var standartSubscriptions = [SKProduct]()
    var promoSubscriptions = [SKProduct]()
    var supportedProductPlans = [LumenSubscriptionPlanType]()
    
    //MARK:- initialization
    init() {
        storeService = RevenueCatService()
        storeService.asObserver().subscribe(onNext: { [weak self] (lumenPurchaseInfo) in
            guard let self = self else { return }
            self.savePurchasedProduct(productIdentifier: lumenPurchaseInfo.productIdentifier)
            self.saveExpirationDate(lumenPurchaseInfo.expirationDate)
            self.updateProtectionStateOnSubscriptionChange()
            VPNEndPointManager.shared.updateVPNCredentials()
        }).disposed(by: disposeBag)

        if getTrialRemainingDays() == nil {
            saveTrialRemainingDays(TrialPeriod)
        }
        self.disableProtectionIfNotAllowedByLicense()
        self.initializeSupportedProducts()
    }
    
    
    
    func saveTrialRemainingDays(_ remainingDays: Int) {
        UserDefaults.standard.set(remainingDays, forKey: trialRemainingDaysKey)
        NotificationCenter.default.post(name: .SubscriptionRefreshNotification, object: nil)
    }
    
    func updateIsProtectionOnState(on: Bool) {
        #if PAID
        UserPreferences.instance.isProtectionOn = on
        #endif
    }
    
    // MARK: Private methods
    private func initializeSupportedProducts() {
        // TODO: put correct ids
        #if BETA
        let basicPlan = LumenSubscriptionPlanType.basic("com.basic")
        let basicVPNPlan = LumenSubscriptionPlanType.basic("com.basic.vpn")
        let VPNPlan = LumenSubscriptionPlanType.basic("com.vpn")
        let promoPlan = LumenSubscriptionPlanType.basic("com.vpn.promo")
        let promoVPNPlan = LumenSubscriptionPlanType.basic("com.vpn.promo1")
        #else
        let basicPlan = LumenSubscriptionPlanType.basic("com.basic")
        let basicVPNPlan = LumenSubscriptionPlanType.basicAndVpn("com.basic.vpn")
        let VPNPlan = LumenSubscriptionPlanType.vpn("com.vpn")
        let promoPlan = LumenSubscriptionPlanType.basic("com.vpn.promo")
        let promoVPNPlan = LumenSubscriptionPlanType.basic("com.vpn.promo1")
        #endif
    
        self.supportedProductPlans.append(basicPlan)
        self.supportedProductPlans.append(basicVPNPlan)
        self.supportedProductPlans.append(VPNPlan)
//        self.supportedProductPlans.append(promoPlan)
//        self.supportedProductPlans.append(promoVPNPlan)
    }
    
    private func saveExpirationDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: expirationDateKey)
    }
    
    private func getExpirationDate() -> Date? {
        return UserDefaults.standard.object(forKey: expirationDateKey) as? Date
    }
    
    private func getTrialRemainingDays() -> Int? {
        return UserDefaults.standard.object(forKey: trialRemainingDaysKey) as? Int
    }
    
    private func savePurchasedProduct(productIdentifier: String) {
        UserDefaults.standard.set(productIdentifier, forKey: purchasedProductIdentifierKey)
    }
    
    private func disableProtectionIfNotAllowedByLicense() {
        #if PAID
        if !self.canEnableProtection() {
            self.updateIsProtectionOnState(on: false)
        }
        #endif
    }
    
    private func updateProtectionStateOnSubscriptionChange() {
        self.updateIsProtectionOnState(on: self.canEnableProtection())
    }
    
    private func canEnableProtection() -> Bool {
        var canEnable = false
        #if PAID
        switch getCurrentSubscription() {
        case .limited:
            canEnable = false
        case .trial(_):
            canEnable = true
        case .premium(let premiumType, _):
            canEnable = premiumType.hasDashboard()
        }
        #endif
        return canEnable
    }
    
    private func subscriptionPlan(for productIdentifier: String) -> LumenSubscriptionPlanType? {
        for supportedPlans in self.supportedProductPlans {
            if supportedPlans.hasAssociatedString(string: productIdentifier) {
                return supportedPlans
            }
        }
        return nil
    }
    
    //MARK:- Subscriptions
    
    func isProductSupported(product: SKProduct) -> Bool {
        for supportedProduct in self.supportedProductPlans {
            if supportedProduct.hasAssociatedString(string: product.productIdentifier) {
                return true
            }
        }
        return false
    }
    public func requestProducts() {
        storeService.requestProducts {[weak self] (success, products) in
            guard let self = self, let products = products, success else { return }
            self.standartSubscriptions.removeAll()
            self.promoSubscriptions.removeAll()
            for product in products {
                if self.isProductSupported(product: product) {
                    // TODO: base on entitlements
                    if product.introductoryPrice != nil {
                        self.promoSubscriptions.append(product)
                    } else {
                        self.standartSubscriptions.append(product)
                    }
                }
            }
        }
    }
    
    public func buyProduct(_ product: SKProduct) {
        storeService.buyProduct(product)
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
    
    public func getCurrentSubscription() -> LumenSubscriptionType {

        if let purchasedProductIdentifier = UserDefaults.standard.string(forKey: purchasedProductIdentifierKey),
            let permiumType = self.subscriptionPlan(for: purchasedProductIdentifier),
            let expirationDate = getExpirationDate(), Date().timeIntervalSince(expirationDate) < 0 {
            return .premium(permiumType, expirationDate)
        }
        // check if trial still valid
        if let trialRemainingDays = getTrialRemainingDays(), trialRemainingDays > 0 {
            return .trial(trialRemainingDays)
        }
        
        // if nothing above succeeded then user has limited subscription
        return .limited
    }
    
    public func getAvailableUpgradeOptions() -> [LumenSubscriptionPlanType] {
        let currentSubscription = getCurrentSubscription()
//        switch currentSubscription {
//        case .premium(let premiumType, _):
//            if premiumType.hasDashboard() {
//                return [.basic, .basicAndVpn]
//            }
//            return [.vpn, .basicAndVpn]
//        default:
//            return [.basic, .basicAndVpn, .vpn]
//        }
        // TODO: PK
        return self.supportedProductPlans
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
    
    public func isDashboardEnabled() -> Bool {
        let currentSubscription = getCurrentSubscription()
        switch currentSubscription {
        case .trial(_):
            return true
        case .premium(let premiumType, _):
            return premiumType.hasDashboard()
        default:
            return false
        }
    }
    
    public func hasSubscription(_ premiumType: LumenSubscriptionPlanType) -> Bool {
        let currentSubscription = getCurrentSubscription()
        switch currentSubscription {
        case .premium(let purchasedPremiumType, _):
            return purchasedPremiumType == premiumType
        default:
            return false
        }
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


