//
//  UILabelExtension.swift
//  Client
//
//  Created by Tim Palade on 5/14/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension UILabel {
    
    func applyShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 0.5
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
    }
    
}
