//
//  PromoSubscriptionsDataSource.swift
//  Client
//
//  Created by Sahakyan on 5/16/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class PromoSubscriptionsDataSource: SubscriptionDataSource {
	
    var promoType: LumenSubscriptionPromoPlanType
    
    init(promoType: LumenSubscriptionPromoPlanType, delegate: SubscriptionDataSourceDelegate) {
        self.promoType = promoType
        super.init(delegate: delegate)
	}

	override func subscriptionInfo(indexPath: IndexPath) -> SubscriptionCellInfo? {
		guard indexPath.row == 0 else {
			return nil
		}
		return self.subscriptionInfo
	}
    
    override func telemeterySignals(product: LumenSubscriptionProduct? = nil) -> [String:String] {
        switch self.promoType.type {
        case .half:
            return ["target" : "subscribe_basic_vpn_offer_half", "view" : "offer_half" ]
        case .freeMonth:
            return ["target" : "subscribe_basic_vpn_offer_free", "view" : "offer_free" ]
        }
    }
    
    override func getHeaderText() -> String? {
        return self.promoType.code
    }
    
    override func getConditionText() -> String {
        switch self.promoType.type {
        case .half:
            return String(format: NSLocalizedString("Payment of %@ will be charged to your Apple ID account each month for 2 months. The subscription automatically renews for %@ per month after 2 months. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "Lumen conditions for 2 months 50% promo"), self.subscriptionInfo?.introductoryPrice ?? "", self.subscriptionInfo?.standardPrice ?? "")
        case .freeMonth:
            return String(format: NSLocalizedString("Your Apple ID account will not be charged in the first month. The subscription automatically renews for %@ per month after 1 month. Subscriptions will be applied to your iTunes account on confirmation. Your account will be charged for renewal within 24 hours prior to the end of the current period at the cost mentioned before. You can cancel anytime in your iTunes account settings until 24 hours before the end of the current period. Any unused portion of a free trial will be forfeited if you purchase a subscription.", tableName: "Lumen", comment: "Lumen conditions for 1 month for free"), self.subscriptionInfo?.standardPrice ?? "")
        }
    }

    override func fetchProducts(completion: ((Bool) -> Void)? = nil) {
        guard let delegate = self.delegate else {
            completion?(false)
            return
        }
        delegate.retrievePromoProducts {[weak self] (products) in
            guard products.count > 0 else {
                completion?(false)
                return
            }
            self?.generateSubscriptionInfos(products: products)
            completion?(true)
        }
    }
    
    // MARK: Private methods
    private var subscriptionInfo: SubscriptionCellInfo? {
        return self.subscriptionInfos.first
    }
    
    private func getPromoPriceDetails() -> String {
        switch self.promoType.type {
        case .half:
            return NSLocalizedString("For 2 months, then", tableName: "Lumen", comment: "Lumen free month price subtitle")
        case .freeMonth:
            return NSLocalizedString("For 1 month, then", tableName: "Lumen", comment: "Lumen free month price subtitle")
        }
    }
    
    private func generateSubscriptionInfos(products: [LumenSubscriptionProduct]) {
        self.subscriptionInfos.removeAll()
        if let promoProduct = products.filter({ $0.product.productIdentifier == self.promoType.promoID }).first {
            self.subscriptionInfos = [SubscriptionCellInfo(priceDetails: nil, promoPriceDetails: self.getPromoPriceDetails(), offerDetails: self.offerDetails(plan: self.promoType), isSubscribed: SubscriptionController.shared.hasSubscription(promoProduct.subscriptionPlan), height: kSubscriptionCellHeight, telemetrySignals: self.telemeterySignals(product: promoProduct), lumenProduct: promoProduct)]
        }
    }
    private func offerDetails(plan: LumenSubscriptionPromoPlanType) -> String? {
        switch plan.type {
        case .half:
            return NSLocalizedString("GET 2 MONTHS AT 50% OFF", tableName: "Lumen", value:"GET 2 MONTHS \nAT 50% OFF", comment: "GET 2 MONTHS AT 50% OFF")
        case .freeMonth:
            return NSLocalizedString("GET 1 MONTH FOR FREE", tableName: "Lumen", value:"GET 1 MONTH \nFOR FREE", comment: "GET 1 MONTH FOR FREE")
        }
    }
}

