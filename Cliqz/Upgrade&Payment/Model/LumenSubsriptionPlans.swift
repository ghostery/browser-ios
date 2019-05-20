//
//  LumenSubsriptionPlans.swift
//  Client
//
//  Created by Sahakyan on 5/17/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

public enum LumenSubscriptionPlanType: String {
	#if BETA
	case basic  = "com.cliqz.ios.lumen.staging.sale.basic"
	case vpn   = "com.cliqz.ios.lumen.staging.sale.vpn"
	case basicAndVpn    = "com.cliqz.ios.lumen.staging.sale.basic_vpn"
	#else
	case basic  = "com.cliqz.ios.lumen.sale.basic"
	case vpn   = "com.cliqz.ios.lumen.sale.vpn"
	case basicAndVpn    = "com.cliqz.ios.lumen.sale.basic_vpn"
	#endif
	
	func hasVPN() -> Bool {
		switch self {
		case .vpn, .basicAndVpn:
			return true
		default:
			return false
		}
	}
	
	func hasDashboard() -> Bool {
		switch self {
		case .basic, .basicAndVpn:
			return true
		default:
			return false
		}
	}
	
}

enum PromoType: String {
	case half = "half"
	case freeMonth = "freeMonth"
}

public struct LumenSubscriptionPromoPlanType {
	let code: String
	let promoID: String
	let type: PromoType
}

//
//#if BETA
//case FirstMonthFree(String, String)
//case HalfPrice(String, String)
//#else
//case FirstMonthFree(String, String)
//case HalfPrice(String, String)
//#endif
