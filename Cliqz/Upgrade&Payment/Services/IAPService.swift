//
//  IAPService.swift
//  Cliqzy
//
//  Created by Mahmoud Adam on 1/23/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit
import RxSwift

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [(product: SKProduct, group: String)]?) -> Void

extension Notification.Name {
    static let ProductPurchaseSuccessNotification = Notification.Name("ProductPurchaseSuccessNotification")
    static let ProductPurchaseErrorNotification = Notification.Name("ProductPurchaseErrorNotification")
    static let ProductPurchaseCancelledNotification = Notification.Name("ProductPurchaseCancelledNotification")
    static let SubscriptionRefreshNotification = Notification.Name("SubscriptionRefreshNotification")
}

protocol IAPService {
    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler)
    func isUserPromoEligible(productID:String, completion: @escaping (Bool) -> Void)
    func buyProduct(_ product: SKProduct)
    func restorePurchases()
    func getSubscriptionUserId() -> String?
    func asObserver() -> PublishSubject<LumenPurchaseInfo>
}

