//
//  LumenSubscriptionProduct.swift
//  Client
//
//  Created by Pavel Kirakosyan on 22.05.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit

open class LumenSubscriptionProduct {
    var product: SKProduct
    var subscriptionPlan: LumenSubscriptionPlanType
    init(product: SKProduct, plan: LumenSubscriptionPlanType) {
        self.product = product
        self.subscriptionPlan = plan
    }
    
    func telemeteryTarget() -> String {
        switch self.subscriptionPlan {
        case .basic:
            return "subscribe_basic"
        case .vpn:
            return "subscribe_vpn"
        case .basicAndVpn:
            return "subscribe_basic_vpn"
        }
    }
}
