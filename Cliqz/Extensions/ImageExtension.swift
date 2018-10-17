//
//  ImageExtension.swift
//  Client
//
//  Created by Tim Palade on 5/3/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension UIImage {
    static func cliqzBackgroundImage(blurred: Bool = false) -> UIImage? {
        
        let (device, orientation) = UIDevice.current.getDeviceAndOrientation()
        let image: UIImage?
        switch device {
        case .iPhone:
            if orientation == .portrait {
                image = UIImage(named: "iPhonePortrait")
            }
            else {
                image = UIImage(named: "iPhoneLandscape")
            }
        case .iPhoneX:
            if orientation == .portrait {
                image = UIImage(named: "iPhoneXPortrait")
            }
            else {
                image = UIImage(named: "iPhoneXLandscape")
            }
        case .iPad:
            if orientation == .portrait {
                image = UIImage(named: "iPadPortrait")
            }
            else {
                image = UIImage(named: "iPadLandscape")
            }
        }
        
        return blurred ? image?.applyBlur(withRadius: 5, blurType: BOXFILTER, tintColor: UIColor.clear, saturationDeltaFactor: 1.0, maskImage: nil) : image
    }

	static func defaultFavicon() -> UIImage? {
		#if PAID
        return UIImage(named: "PaidFavicon")
        #else
        return UIImage(named: "ghosteryFavicon")
        #endif
	}
    
    static func tabTrayGhostModeIcon() -> UIImage? {
        #if PAID
            return UIImage(named: "ghost_mode_Paid")
        #else
            return UIImage(named: "ghost_mode_Ghostery")
        #endif
        
    }
    
    static func controlCenterNormalIcon() -> UIImage? {
        #if PAID
        return UIImage(named: "control_center_normal_Paid")
        #else
        return UIImage(named: "ghosty")
        #endif
    }
    
    static func controlCenterPrivateIcon() -> UIImage? {
        #if PAID
        return UIImage(named: "control_center_private_Paid")
        #else
        return UIImage(named: "ghostyPrivate")
        #endif
    }
    
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
