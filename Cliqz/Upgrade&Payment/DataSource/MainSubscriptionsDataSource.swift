//
//  MainSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class MainSubscriptionsDataSource {
	
	private let subscriptionPlans: [LumenSubscriptionPlanType] = SubscriptionController.shared.getAvailableUpgradeOptions()

	init() {
	}
	
	func subscriptionsCount() -> Int {
		return subscriptionPlans.count
	}

	func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
		let premiumType = self.subscriptionPlans[indexPath.row]
        switch premiumType {
        case .basicAndVpn(_):
            return 150
        default:
            return 135.0
        }
	}

	//TODO offr text
	func subscriptionInfo(indexPath: IndexPath) -> SubscriptionInfo? {
		let plan = subscriptionPlans[indexPath.row]
        guard let productIdentifier = plan.associatedString() else {
            return nil
        }
		var offerDetails: String? = nil
		switch plan {
		case .basicAndVpn:
			offerDetails = NSLocalizedString("BEST OFFER LIMITED TIME ONLY", tableName: "Lumen", value:"BEST OFFER\nLIMITED TIME ONLY", comment: "BEST OFFER\nLIMITED TIME ONLY")
		default:
			break
		}
        
        return SubscriptionInfo(subscriptionID: productIdentifier, name: getName(of: plan), price: getPrice(of: plan), priceDetails: nil, description: getDescription(of: plan), offerDetails: offerDetails, isSubscribed: SubscriptionController.shared.hasSubscription(plan))
	}
	
	func getName(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return NSLocalizedString("BASIC", tableName: "Lumen", comment: "BASIC Subscription name")
		case .vpn:
			return NSLocalizedString("VPN", tableName: "Lumen", comment: "VPN Subscription name")
		case .basicAndVpn:
			return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
		}
	}
	
	func getDescription(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return NSLocalizedString("ULTIMATE PROTECTION ONLINE", tableName: "Lumen", comment: "BASIC Subscription Description")
		case .vpn:
			return NSLocalizedString("PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", comment: "VPN Subscription Description")
		case .basicAndVpn:
			return NSLocalizedString("ULTIMATE PROTECTION ONLINE PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", value: "ULTIMATE PROTECTION ONLINE +\nPROTECTION FROM HACKERS WITH VPN", comment: "Basic + VPN Subscription Description")
		}
	}
	
	func getPrice(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return NSLocalizedString("1,99 €/MONTH", tableName: "Lumen", comment: "BASIC Subscription price")
		case .vpn:
			return NSLocalizedString("4,99 €/MONAT", tableName: "Lumen", comment: "VPN Subscription price")
		case .basicAndVpn:
			return NSLocalizedString("4,99 €/MONTH", tableName: "Lumen", comment: "Basic + VPN Subscription price")
		}
	}
	
	func getTelemeteryTarget(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return "subscribe_basic"
		case .vpn:
			return "subscribe_vpn"
		case .basicAndVpn:
			return "subscribe_basic_vpn"
		}
	}


}
