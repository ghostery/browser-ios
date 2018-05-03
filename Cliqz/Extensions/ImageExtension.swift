//
//  ImageExtension.swift
//  Client
//
//  Created by Tim Palade on 5/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension UIImage {
    static func cliqzBackgroundImage() -> UIImage? {
        
        let (device, orientation) = UIDevice.current.getDeviceAndOrientation()
        
        switch device {
        case .iPhone:
            if orientation == .portrait {
                return UIImage(named: "iPhonePortrait")
            }
            return UIImage(named: "iPhoneLandscape")
        case .iPhoneX:
            if orientation == .portrait {
                return UIImage(named: "iPhoneXPortrait")
            }
            return UIImage(named: "iPhoneXLandscape")
        case .iPad:
            if orientation == .portrait {
                return UIImage(named: "iPadPortrait")
            }
            return UIImage(named: "iPadLandscape")
        }
    }
}
