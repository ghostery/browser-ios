//
//  UIHelpers.swift
//  Client
//
//  Created by Tim Palade on 5/14/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class UIHelper {
    static func heightURLBar(_ device: DeviceType, _ orientation: DeviceOrientation) -> CGFloat {
        
        let top: CGFloat
        
        if (device == .iPhone || device == .iPhoneX) {
            if orientation == .portrait {
                top = 76.0
            }
            else {
                top = 56.0
            }
        }
        else {
            top = 120.0
        }
        
        return top
    }
    
    static func screenWidthDenominator(_ device: DeviceType, _ orientation: DeviceOrientation) -> CGFloat {
        if device != .iPad && orientation == .portrait {
            return 1.0
        }
        else if device == .iPad {
            return 2.0
        }
        else {
            return 1.5
        }
    }
    
    static func panLimitDenominator(_ device: DeviceType, _ orientation: DeviceOrientation) -> CGFloat {
        if device != .iPad && orientation == .portrait {
            return 10.0
        }
        else if device == .iPad {
            return 10.0
        }
        else {
            return 8.0
        }
    }

}
