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
    init(products: [LumenSubscriptionProduct]) {
        self.generateSubscriptionInfos(products: products)
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
    private func telemeterySignals(product: LumenSubscriptionProduct) -> [String:String] {
        switch product.subscriptionPlan {
        case .basic:
            return ["target" : "subscribe_basic", "view" : "regular" ]
        case .vpn:
            return ["target" : "subscribe_vpn", "view" : "regular" ]
        case .basicAndVpn:
            return ["target" : "subscribe_basic_vpn", "view" : "regular" ]
        }
    }
    
    private func generateSubscriptionInfos(products: [LumenSubscriptionProduct]) {
        self.subscriptionInfos.removeAll()
        for product in products {
            var offerDetails: String? = nil
            var height:CGFloat = 135.0
            switch product.subscriptionPlan {
            case .basicAndVpn(_):
                offerDetails = NSLocalizedString("BEST OFFER LIMITED TIME ONLY", tableName: "Lumen", value:"BEST OFFER\nLIMITED TIME ONLY", comment: "BEST OFFER\nLIMITED TIME ONLY")
                height = 150
            default:
                break
            }
            let telemetries = self.telemeterySignals(product: product)
			let info = SubscriptionCellInfo(priceDetails: nil, promoPriceDetails: nil, offerDetails: offerDetails, isSubscribed: SubscriptionController.shared.hasSubscription(product.subscriptionPlan), height: height, telemetrySignals: telemetries, lumenProduct: product)
            self.subscriptionInfos.append(info)
        }
        self.subscriptionInfos.sort { (left, right) -> Bool in
            return left.lumenProduct.subscriptionPlan < right.lumenProduct.subscriptionPlan
        }
    }

}
