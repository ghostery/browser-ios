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
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

protocol IAPService {
    func requestProducts(completionHandler: @escaping ProductsRequestCompletionHandler)
    func buyProduct(_ product: SKProduct)
    func restorePurchases()
    func getSubscriptionUserId() -> String?
    func asObserver() -> PublishSubject<LumenPurchaseInfo>
}
