//
//  LumenSubscriptionType.swift
//  Cliqzy
//
//  Created by Mahmoud Adam on 1/14/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

public enum LumenSubscriptionType {
    case limited
    case trial(Int)
    case premium(LumenSubscriptionPlanType, Date)
    
    func trialRemainingDays() -> Int? {
        switch self {
        case .trial(let remainingDays):
            return remainingDays
        default:
            return nil
        }
    }
    func isLimitedSubscription() -> Bool {
        switch self {
        case .limited:
            return true
        default:
            return false
        }
    }
    
    func getTelegetryState() -> String {
        switch self {
        case .limited:
            return "free"
        case .trial(_):
            return "trial"
        case .premium(let premiumType, _):
            return premiumType.hasVPN() ? "plus" : "basic"
        }
    }
    
    func description() -> String {
        switch self {
        case .limited:
            return "free"
        case .trial(_):
            return "trial"
        case .premium(let premiumType, _):
            switch premiumType {
            case .basic(_):
                return "basic"
            case .basicAndVpn(_):
                return "basic_vpn"
            case .vpn(_):
                return "vpn"
            }
        }
    }
}
