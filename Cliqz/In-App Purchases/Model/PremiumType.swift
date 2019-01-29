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
}
