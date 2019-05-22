//
//  MainSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import StoreKit

class StandardSubscriptionsDataSource {
	
    var subscriptionInfos = [SubscriptionCellInfo]()
    init(subscriptions: [(product: SKProduct,plan: LumenSubscriptionPlanType)]) {
        self.generateSubscriptionInfos(subscriptions: subscriptions)
    }
	
	func subscriptionsCount() -> Int {
		return self.subscriptionInfos.count
	}

	func subscriptionHeight(indexPath: IndexPath) -> CGFloat {
		let subscription = self.subscriptionInfos[indexPath.row]
        return subscription.height
	}

	func subscriptionInfo(indexPath: IndexPath) -> SubscriptionCellInfo? {
		return self.subscriptionInfos[indexPath.row]
	}
    
    // MARK: Private methods
	
	private func getName(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return NSLocalizedString("BASIC", tableName: "Lumen", comment: "BASIC Subscription name")
		case .vpn:
			return NSLocalizedString("VPN", tableName: "Lumen", comment: "VPN Subscription name")
		case .basicAndVpn:
			return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
		}
	}
	
	private func getDescription(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return NSLocalizedString("ULTIMATE PROTECTION ONLINE", tableName: "Lumen", comment: "BASIC Subscription Description")
		case .vpn:
			return NSLocalizedString("PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", comment: "VPN Subscription Description")
		case .basicAndVpn:
			return NSLocalizedString("ULTIMATE PROTECTION ONLINE PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", value: "ULTIMATE PROTECTION ONLINE +\nPROTECTION FROM HACKERS WITH VPN", comment: "Basic + VPN Subscription Description")
		}
	}
	
	
	private func getTelemeteryTarget(of plan: LumenSubscriptionPlanType) -> String {
		switch plan {
		case .basic:
			return "subscribe_basic"
		case .vpn:
			return "subscribe_vpn"
		case .basicAndVpn:
			return "subscribe_basic_vpn"
		}
	}

    private func generateSubscriptionInfos(subscriptions: [(product: SKProduct,plan: LumenSubscriptionPlanType)]) {
        self.subscriptionInfos.removeAll()
        for subscription in subscriptions {
            var offerDetails: String? = nil
            var height:CGFloat = 135.0
            switch subscription.plan {
            case .basicAndVpn(_):
                offerDetails = NSLocalizedString("BEST OFFER LIMITED TIME ONLY", tableName: "Lumen", value:"BEST OFFER\nLIMITED TIME ONLY", comment: "BEST OFFER\nLIMITED TIME ONLY")
                height = 150
            default:
                break
            }
            let info = SubscriptionCellInfo(name: self.getName(of: subscription.plan), priceDetails: nil, description: self.getDescription(of: subscription.plan), offerDetails: offerDetails, isSubscribed: SubscriptionController.shared.hasSubscription(subscription.plan), height: height, product: subscription.product)
            self.subscriptionInfos.append(info)
        }
    }

}
