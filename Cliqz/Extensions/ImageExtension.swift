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
}
