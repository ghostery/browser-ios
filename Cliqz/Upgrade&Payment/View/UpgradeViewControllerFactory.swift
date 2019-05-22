//
//  UpgradeViewControllerFactory.swift
//  Client
//
//  Created by Sahakyan on 5/21/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class UpgradeViewControllerFactory {
    #if PAID
	class func standardUpgradeViewController() -> UIViewController {
		let subscirptionPlans = SubscriptionController.shared.getAvailableUpgradeOptions()
		let dataSource = StandardSubscriptionsDataSource(products: subscirptionPlans)
		let upgradLumenViewController = UpgradLumenViewController(dataSource)
		let navController = UpgradLumenNavigationController(rootViewController: upgradLumenViewController)
		return navController
	}

	class func promoUpgradeViewController(promoCode: String) -> PromoUpgradeViewController? {
		if let promoType = PromoCodesManager.shared.getPromoType(promoCode) {
			// TODO: producs list should be provided
			let promoDataSource = PromoSubscriptionsDataSource(promoType: promoType, availablePromoSubscription: SubscriptionController.shared.promoSubscriptionProducts)
			let promoViewController = PromoUpgradeViewController(promoDataSource)
			return promoViewController
		}
		return nil
	}
    #endif
}
