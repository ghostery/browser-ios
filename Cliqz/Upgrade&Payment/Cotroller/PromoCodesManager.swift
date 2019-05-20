//
//  PromoCodesManager.swift
//  Client
//
//  Created by Sahakyan on 5/15/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import SwiftyJSON

class PromoCodesManager {

//	private var promoCodes: [String: JSON]?
	private var promoCodes = [String: LumenSubscriptionPromoPlanType]()

	func isValidPromoCode(_ code: String) -> Bool {
		return self.promoCodes[code] != nil
	}

	func getPromoType(_ code: String) -> LumenSubscriptionPromoPlanType? {
		if let plan = self.promoCodes[code] {
			return plan
		}
		return nil
	}

	init() {
		loadAllPromoCodes()
	}

	private func loadAllPromoCodes() {
		DispatchQueue.global().async {
			if let jsonFilePath = Bundle.main.url(forResource: "promoCodes", withExtension: "json"),
				let data = try? Data(contentsOf: jsonFilePath) {
				if let promos = JSON(data: data).array {
					for promo in promos {
						if let promoDict = promo.dictionary,
							let code = promoDict["code"]?.string,
							let promoID = promoDict["ID"]?.string,
							let strType = promoDict["type"]?.string,
							let type = PromoType(rawValue: strType) {
							self.promoCodes[code] = LumenSubscriptionPromoPlanType(code: code, promoID: promoID, type: type)
						}
					}
				}
			}
		}
	}
}
