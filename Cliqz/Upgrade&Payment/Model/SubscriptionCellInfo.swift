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
	let priceDetails: String?
	let promoPriceDetails: String?
	let offerDetails: String?
	let isSubscribed: Bool
    let height: CGFloat
    let telemetrySignals: [String:String]
    var lumenProduct: LumenSubscriptionProduct
    var localizedPrice: String {
        // in future the period also can be dinamically taken from product. see subscriptionPeriod property
        return String("\(self.introductoryPrice) \(NSLocalizedString("/MONTH", tableName: "Lumen", comment: "Subscription price period"))")
    }
    var name: String {
        switch self.lumenProduct.subscriptionPlan {
        case .basic:
            return NSLocalizedString("BASIC", tableName: "Lumen", comment: "BASIC Subscription name")
        case .vpn:
            return NSLocalizedString("VPN", tableName: "Lumen", comment: "VPN Subscription name")
        case .basicAndVpn:
            return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
        }
    }
    
    var description: String {
        switch self.lumenProduct.subscriptionPlan {
        case .basic:
            return NSLocalizedString("ULTIMATE PROTECTION ONLINE", tableName: "Lumen", comment: "BASIC Subscription Description")
        case .vpn:
            return NSLocalizedString("PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", comment: "VPN Subscription Description")
        case .basicAndVpn:
            return NSLocalizedString("ULTIMATE PROTECTION ONLINE PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", value: "ULTIMATE PROTECTION ONLINE +\nPROTECTION FROM HACKERS WITH VPN", comment: "Basic + VPN Subscription Description")
        }
    }
    
    var standardPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = lumenProduct.product.priceLocale
        let formattedPrice = formatter.string(from: lumenProduct.product.price) ?? ""
        return formattedPrice
    }
    
    var introductoryPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = lumenProduct.product.priceLocale
        let formattedPrice = formatter.string(from: lumenProduct.product.introductoryPrice?.price ?? lumenProduct.product.price) ?? ""
        return formattedPrice
    }
	
	var promoPriceLocalizedDetails: String? {
		if let promoPriceDetails = self.promoPriceDetails {
			return String("\(promoPriceDetails) \(self.standardPrice)\(NSLocalizedString("/MONTH", tableName: "Lumen", comment: "Subscription price period"))")
		}
		return nil
	}
}
