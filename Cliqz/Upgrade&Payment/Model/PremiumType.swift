//
//  PremiumType.swift
//  Client
//
//  Created by Mahmoud Adam on 1/29/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

public enum PremiumType: String {
    case Basic  = "com.cliqz.ios.lumen.basic"
    case Plus   = "com.cliqz.ios.lumen.plus"
    case Pro    = "com.cliqz.ios.lumen.pro"
    
    func hasVPN() -> Bool {
        switch self {
        case .Plus, .Pro:
            return true
        default:
            return false
        }
    }
    
    func getName() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("BASIC", tableName: "Lumen", comment: "BASIC Subscription name")
        case .Plus:
            return NSLocalizedString("PLUS", tableName: "Lumen", comment: "PLUS Subscription name")
        case .Pro:
            return NSLocalizedString("PRO", tableName: "Lumen", comment: "PRO Subscription name")
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("ULTIMATE PROTECTION: AD-BLOCKER · ANTI-TRACKING · ANTI-PHISHING", tableName: "Lumen", comment: "BASIC Subscription Description")
        case .Plus:
            return NSLocalizedString("VPN · ULTIMATE PROTECTION: DASHBOARD · AD-BLOCKER · ANTI-TRACKING · ANTI-PHISHING", tableName: "Lumen", comment: "PLUS Subscription Description")
        case .Pro:
            return NSLocalizedString("VPN · ULTIMATE PROTECTION: DASHBOARD · AD-BLOCKER · ANTI-TRACKING · ANTI-PHISHING", tableName: "Lumen", comment: "PRO Subscription Description")
        }
    }
    
    func getDuration() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("12 MONTHS", tableName: "Lumen", comment: "BASIC Subscription duration")
        case .Plus:
            return NSLocalizedString("12 MONTHS", tableName: "Lumen", comment: "PLUS Subscription duration")
        case .Pro:
            return NSLocalizedString("1 MONTH", tableName: "Lumen", comment: "PRO Subscription duration")
        }
    }
    
    func getPrice() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("4€/month", tableName: "Lumen", comment: "BASIC Subscription price")
        case .Plus:
            return NSLocalizedString("8€/month", tableName: "Lumen", comment: "PLUS Subscription price")
        case .Pro:
            return NSLocalizedString("9.99€/month", tableName: "Lumen", comment: "PRO Subscription price")
        }
    }
    
    
    func getBilling() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("Billed annually: 47.99€", tableName: "Lumen", comment: "BASIC Subscription billing")
        case .Plus:
            return NSLocalizedString("Billed annually: 95.99€", tableName: "Lumen", comment: "PLUS Subscription billing")
        case .Pro:
            return NSLocalizedString("Billed monthly", tableName: "Lumen", comment: "PRO Subscription billing")
        }
    }
    
}