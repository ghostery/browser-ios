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

public typealias LumenProductRequestCompletion = ([LumenSubscriptionProduct], [LumenSubscriptionProduct]) -> Void

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
    private var isProductRequestInProgress = false
    private var productRequestCompletions: [LumenProductRequestCompletion] = []
    
    var standardSubscriptionProducts = [LumenSubscriptionProduct]()
    var promoSubscriptionProducts = [LumenSubscriptionProduct]()
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
        #if BETA
        let basicPlan = LumenSubscriptionPlanType.basic("com.cliqz.ios.lumen.staging.sale.basic")
        let basicVPNPlan = LumenSubscriptionPlanType.basic("com.cliqz.ios.lumen.staging.sale.basic_vpn")
        let VPNPlan = LumenSubscriptionPlanType.basic("com.cliqz.ios.lumen.staging.sale.vpn")
        let promoFree = LumenSubscriptionPlanType.basicAndVpn("com.cliqz.ios.lumen.staging.promo.free.basic_vpn")
        let promoHalf = LumenSubscriptionPlanType.basicAndVpn("com.cliqz.ios.lumen.staging.promo.half.basic_vpn")
        #else
        let basicPlan = LumenSubscriptionPlanType.basic("com.cliqz.ios.lumen.sale.basic")
        let basicVPNPlan = LumenSubscriptionPlanType.basicAndVpn("com.cliqz.ios.lumen.sale.basic_vpn")
        let VPNPlan = LumenSubscriptionPlanType.vpn("com.cliqz.ios.lumen.sale.vpn")
        let promoFree = LumenSubscriptionPlanType.basicAndVpn("com.cliqz.ios.lumen.promo.free.basic_vpn")
        let promoHalf = LumenSubscriptionPlanType.basicAndVpn("com.cliqz.ios.lumen.promo.half.basic_vpn")
        #endif
    
        self.supportedProductPlans.append(basicPlan)
        self.supportedProductPlans.append(basicVPNPlan)
        self.supportedProductPlans.append(VPNPlan)
        self.supportedProductPlans.append(promoFree)
        self.supportedProductPlans.append(promoHalf)
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
    
    private func supportedSubscriptionPlan(for productIdentifier: String) -> LumenSubscriptionPlanType? {
        for supportedPlans in self.supportedProductPlans {
            if supportedPlans.hasAssociatedString(string: productIdentifier) {
                return supportedPlans
            }
        }
        return nil
    }
    
    private func productsReceived(products: [(product: SKProduct, group: String)]) {
        self.standardSubscriptionProducts.removeAll()
        self.promoSubscriptionProducts.removeAll()
        for productPair in products {
            let product = productPair.product
            if let plan = self.supportedSubscriptionPlan(for: product.productIdentifier) {
                let lumenProduct = LumenSubscriptionProduct(product: product, plan: plan)
                if productPair.group == "Premium Promo" {
                    self.promoSubscriptionProducts.append(lumenProduct)
                } else {
                    self.standardSubscriptionProducts.append(lumenProduct)
                }
            }
        }
    }
    
    //MARK:- Subscriptions
    public func requestProducts(completion:LumenProductRequestCompletion? = nil) {
        if let completion = completion {
            self.productRequestCompletions.append(completion)
        }
        guard !self.isProductRequestInProgress else {
            return
        }
        
        self.isProductRequestInProgress = true
        storeService.requestProducts {[weak self] (success, products) in
            guard let self = self else { return }
            guard let products = products, success else {
                self.isProductRequestInProgress = false
                self.productRequestCompletions.forEach({ (block) in
                    block(self.standardSubscriptionProducts, self.promoSubscriptionProducts)
                })
                return
            }
            
            self.productsReceived(products: products)
            
            self.productRequestCompletions.forEach({ (block) in
                block(self.standardSubscriptionProducts, self.promoSubscriptionProducts)
            })
            
            self.isProductRequestInProgress = false
            self.productRequestCompletions.removeAll()
        }
    }
    
    public func isEligible(for productID: String, completion:@escaping (Bool) -> Void) {
        storeService.isUserPromoEligible(productID: productID, completion: completion)
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
            let permiumType = self.supportedSubscriptionPlan(for: purchasedProductIdentifier),
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
    
    public func getAvailableUpgradeOptions() -> [LumenSubscriptionProduct] {
        let currentSubscription = getCurrentSubscription()
        
        switch currentSubscription {
        case .premium(let premiumType, _):
            let availableSubscriptions = self.standardSubscriptionProducts.filter { $0.subscriptionPlan != premiumType }
            return availableSubscriptions
        default:
            return self.standardSubscriptionProducts
        }
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

extension SubscriptionController: SubscriptionDataSourceDelegate {
    func retrievePromoProducts(completion:@escaping ([LumenSubscriptionProduct]) -> Void) {
        if self.promoSubscriptionProducts.count > 0 {
            completion(self.promoSubscriptionProducts)
        } else {
            self.requestProducts { (standart, promo) in
                completion(promo)
            }
        }
    }
    
    func retrieveStandartProducts(completion:@escaping ([LumenSubscriptionProduct]) -> Void) {
        if self.standardSubscriptionProducts.count > 0 {
            completion(self.standardSubscriptionProducts)
        } else {
            self.requestProducts { (standart, promo) in
                completion(standart)
            }
        }
    }
}


