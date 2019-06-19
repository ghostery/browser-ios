//
//  LumenSubsriptionPlans.swift
//  Client
//
//  Created by Sahakyan on 5/17/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

public enum LumenSubscriptionPlanType {
	case basic(String)
	case vpn(String)
	case basicAndVpn(String)

    func hasAssociatedString(string: String) -> Bool {
        guard let associatedString = self.associatedString() else {
            return false
        }
        return string.contains(associatedString)
    }
    
    func associatedString() -> String? {
        switch self {
        case .basic(let val):
            return val
        case .basicAndVpn(let val):
            return val
        case .vpn(let val):
            return val
        }
    }

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

extension LumenSubscriptionPlanType: Equatable {
    public static func ==(lhs: LumenSubscriptionPlanType, rhs:LumenSubscriptionPlanType) -> Bool {
        switch lhs {
        case .basic(_):
            switch rhs {
            case .basic(_):
                return true
            default:
                return false
            }
        case .basicAndVpn(_):
            switch rhs {
            case .basicAndVpn:
                return true
            default:
                return false
            }
        case .vpn:
            switch rhs {
            case .vpn:
                return true
            default:
                return false
            }
        }
    }
    
    public static func <(lhs: LumenSubscriptionPlanType, rhs:LumenSubscriptionPlanType) -> Bool {
        switch lhs {
        case .basic(_):
           return true
        case .basicAndVpn(_):
            switch rhs {
            case .vpn:
                return true
            default:
                return false
            }
        case .vpn:
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

