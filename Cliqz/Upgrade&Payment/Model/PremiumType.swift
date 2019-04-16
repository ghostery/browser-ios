//
//  PremiumType.swift
//  Client
//
//  Created by Mahmoud Adam on 1/29/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

public enum PremiumType: String {
    #if BETA
    case Basic  = "com.cliqz.ios.lumen.staging.sale.basic"
    case Vpn   = "com.cliqz.ios.lumen.staging.sale.vpn"
    case BasicAndVpn    = "com.cliqz.ios.lumen.staging.sale.basic_vpn"
    #else
    case Basic  = "com.cliqz.ios.lumen.sale.basic"
    case Vpn   = "com.cliqz.ios.lumen.sale.vpn"
    case BasicAndVpn    = "com.cliqz.ios.lumen.sale.basic_vpn"
    #endif
    
    func hasVPN() -> Bool {
        switch self {
        case .Vpn, .BasicAndVpn:
            return true
        default:
            return false
        }
    }
    
    func hasDashboard() -> Bool {
        switch self {
        case .Basic, .BasicAndVpn:
            return true
        default:
            return false
        }
    }
    
    func getName() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("BASIC", tableName: "Lumen", comment: "BASIC Subscription name")
        case .Vpn:
            return NSLocalizedString("VPN", tableName: "Lumen", comment: "VPN Subscription name")
        case .BasicAndVpn:
            return NSLocalizedString("BASIC + VPN", tableName: "Lumen", comment: "Basic + VPN Subscription name")
        }
    }
    
    func getDescription() -> String {
        switch self {
        case .Basic:
            return NSLocalizedString("ULTIMATE PROTECTION ONLINE", tableName: "Lumen", comment: "BASIC Subscription Description")
        case .Vpn:
            return NSLocalizedString("PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", comment: "VPN Subscription Description")
        case .BasicAndVpn:
			return NSLocalizedString("ULTIMATE PROTECTION ONLINE PROTECTION FROM HACKERS WITH VPN", tableName: "Lumen", value: "ULTIMATE PROTECTION ONLINE +\nPROTECTION FROM HACKERS WITH VPN", comment: "Basic + VPN Subscription Description")
        }
    }
    
    func getPrice() -> String {
        switch self {
        case .Basic:
			return NSLocalizedString("1,99 €/MONTH", tableName: "Lumen", comment: "BASIC Subscription price")
        case .Vpn:
			return NSLocalizedString("4,99 €/MONAT", tableName: "Lumen", comment: "VPN Subscription price")
        case .BasicAndVpn:
			return NSLocalizedString("4,99 €/MONTH", tableName: "Lumen", comment: "Basic + VPN Subscription price")
        }
    }
    
    func getTelemeteryTarget() -> String {
        switch self {
        case .Basic:
            return "subscribe_basic"
        case .Vpn:
            return "subscribe_vpn"
        case .BasicAndVpn:
            return "subscribe_basic_vpn"
        }
    }
}
