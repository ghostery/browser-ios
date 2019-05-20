//
//  PromoSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class PromoSubscriptionsDataSource {
	
	private let subscriptionPlan: LumenSubscriptionPromoPlanType
	
	init(promoType: LumenSubscriptionPromoPlanType) {
		subscriptionPlan = promoType
	}

	func subscriptionsCount() -> Int {
		return 1
	}

	func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
			return 150
	}

	//TODO offr text
	func subscriptionInfo(indexPath: IndexPath) -> SubscriptionInfo? {
		guard indexPath.row == 0 else {
			return nil
		}
		var offerDetails: String? = nil
		switch subscriptionPlan.type {
		case .half:
			offerDetails = NSLocalizedString("GET 2 MONTHS AT 50% OFF", tableName: "Lumen", value:"GET 2 MONTHS \nAT 50% OFF", comment: "GET 2 MONTHS AT 50% OFF")
		default:
			break
		}
        return SubscriptionInfo(subscriptionID: subscriptionPlan.promoID, name: getName(), price: getPrice(), priceDetails: nil, description: getDescription(), offerDetails: offerDetails, isSubscribed: false)
	}

	func getName() -> String {
		return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
		// GET 1 MONTH nFOR FREE
	}

	func getDescription() -> String {
		return NSLocalizedString("ULTIMATE PROTECTION ONLINE PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", value: "ULTIMATE PROTECTION ONLINE +\nPROTECTION FROM HACKERS WITH VPN", comment: "Basic + VPN Subscription Description")
	}

	func getPrice() -> String {
		// TODO: should be localized and corresponding to the plan
		return NSLocalizedString("4,99 €/MONTH", tableName: "Lumen", comment: "Basic + VPN Subscription price")
	}

	func getConditionText() -> String {
		// TODO: Should be localized and parametrized
		return "Payment of 2.49€ will be charged to your Apple ID account each month for 2 months. The subscription automatically renews for 4.99€ per month after 2 months. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription."
	}

	func getTelemeteryTarget() -> String {
		// TODO:
		return ""
	}
}

