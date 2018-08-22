//
//  UIViewExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 8/22/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension UIView {
    class func overlay(frame: CGRect, alpha: CGFloat = 0.5) -> UIView {
        let overlay = UIView(frame: frame)
        overlay.backgroundColor = UIColor.black
        overlay.alpha = alpha
        return overlay
    }
}
