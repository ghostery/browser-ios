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
    case premium(LumenSubsriptionPlanType, Date)
    
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
}
