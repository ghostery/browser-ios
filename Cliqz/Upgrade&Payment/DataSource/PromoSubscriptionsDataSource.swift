//
//  PromoSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class PromoSubscriptionsDataSource {
	
    private var subscriptionInfo: SubscriptionCellInfo? 
	
    init(promoType: LumenSubscriptionPromoPlanType, availablePromoSubscription: [LumenSubscriptionProduct]) {
        if let promoProduct = availablePromoSubscription.filter({ $0.product.productIdentifier == promoType.promoID }).first {
            self.subscriptionInfo = SubscriptionCellInfo(priceDetails: nil, offerDetails: self.offerDetails(plan: promoType), isSubscribed: SubscriptionController.shared.hasSubscription(promoProduct.subscriptionPlan), height: 150, lumenProduct: promoProduct)
        }
	}

	func subscriptionsCount() -> Int {
		return 1
	}

	func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
        return self.subscriptionInfo?.height ?? 0
	}

	//TODO offr text
	func subscriptionInfo(indexPath: IndexPath) -> SubscriptionCellInfo? {
		guard indexPath.row == 0 else {
			return nil
		}
		return self.subscriptionInfo
	}

	func getName() -> String {
		return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
		// GET 1 MONTH nFOR FREE
	}

	func getConditionText() -> String {
		// TODO: Should be localized and parametrized
		return "Payment of 2.49€ will be charged to your Apple ID account each month for 2 months. The subscription automatically renews for 4.99€ per month after 2 months. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription."
	}
    
    
    private func offerDetails(plan: LumenSubscriptionPromoPlanType) -> String? {
        switch plan.type {
        case .half:
            return NSLocalizedString("GET 2 MONTHS AT 50% OFF", tableName: "Lumen", value:"GET 2 MONTHS \nAT 50% OFF", comment: "GET 2 MONTHS AT 50% OFF")
        default:
            break
        }
        return nil
    }
}

