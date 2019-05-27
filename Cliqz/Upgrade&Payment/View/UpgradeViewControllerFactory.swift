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
        let dataSource = StandardSubscriptionsDataSource(delegate: SubscriptionController.shared)
		let upgradLumenViewController = UpgradLumenViewController(dataSource)
		let navController = UpgradLumenNavigationController(rootViewController: upgradLumenViewController)
		return navController
	}

	class func promoUpgradeViewController(promoCode: String) -> PromoUpgradeViewController? {
		if let promoType = PromoCodesManager.shared.getPromoType(promoCode) {
			let promoDataSource = PromoSubscriptionsDataSource(promoType: promoType, delegate: SubscriptionController.shared)
			let promoViewController = PromoUpgradeViewController(promoDataSource)
			return promoViewController
		}
		return nil
	}
    #endif
}
