//
//  ThemeExtentions.swift
//  Client
//
//  Created by Mahmoud Adam on 12/25/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension URLBarColor {
    @objc var urlbarButtonTitleText: UIColor { return UIColor.black }
    @objc var urlbarButtonTint: UIColor { return UIColor.Photon.Grey80 }
}

extension DarkURLBarColor {
    override var urlbarButtonTitleText: UIColor { return UIColor.white }
    override var urlbarButtonTint: UIColor { return UIColor.Photon.Grey10 }
}
