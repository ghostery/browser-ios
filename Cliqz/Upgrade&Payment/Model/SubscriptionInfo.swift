//
//  SubscriptionInfo.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit

struct SubscriptionCellInfo {
	let name: String
	let priceDetails: String?
	let description: String
	let offerDetails: String?
	let isSubscribed: Bool
    let height: CGFloat
    weak var product: SKProduct?
    var price: String {
        guard let product = self.product else {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        return formatter.string(from: product.price) ?? ""
    }
}
