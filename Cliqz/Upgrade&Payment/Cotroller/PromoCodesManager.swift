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

	private var promoCodes = [String: LumenSubscriptionPromoPlanType]()

	static let shared = PromoCodesManager()

	func isValidPromoCode(_ code: String) -> Bool {
		return self.promoCodes[code.lowercased()] != nil
	}

	func getPromoType(_ code: String) -> LumenSubscriptionPromoPlanType? {
		if let plan = self.promoCodes[code.lowercased()] {
			return plan
		}
		return nil
	}

	init() {
		loadAllPromoCodes()
	}

	private func loadAllPromoCodesFromJSONFile() {
		DispatchQueue.global().async {
			if let jsonFilePath = Bundle.main.url(forResource: "promoCodes", withExtension: "json"),
				let data = try? Data(contentsOf: jsonFilePath) {
				if let promos = JSON(data: data).array {
					self.initializePromoCodes(dictionaries: promos)
				}
			}
		}
	}
    
    private func loadAllPromoCodes() {
        self.initializePromoCodes(dictionaries: self.staticPromoList)
    }
    
    private func initializePromoCodes(dictionaries: [JSON]) {
        for promo in dictionaries {
            if let promoDict = promo.dictionary,
                let code = promoDict["code"]?.string?.lowercased(),
                let promoID = promoDict["ID"]?.string,
                let strType = promoDict["type"]?.string,
                let type = PromoType(rawValue: strType) {
                self.promoCodes[code] = LumenSubscriptionPromoPlanType(code: code, promoID: promoID, type: type)
            }
        }
    }
    
    private var staticPromoList: [JSON] {
        let promo1 = ["code": "OHBABY", "ID": "com.cliqz.ios.lumen.promo.free.basic_vpn", "type": "freeMonth"] as [String: Any]
        let promo2 = ["code": "OBABY", "ID": "com.cliqz.ios.lumen.promo.free.basic_vpn", "type": "freeMonth"] as [String: Any]
        let promo3 = ["code": "LUMEN2019", "ID": "com.cliqz.ios.lumen.promo.half.basic_vpn", "type": "half"]
        return [JSON(promo1), JSON(promo2), JSON(promo3)]
    }
}
