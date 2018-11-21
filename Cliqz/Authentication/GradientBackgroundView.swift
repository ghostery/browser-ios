//
//  GradientBackgroundView.swift
//  Client
//
//  Created by Sahakyan on 11/20/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class GradientBackgroundView: UIView {

	let gradient: CAGradientLayer = CAGradientLayer()
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	init() {
		super.init(frame: CGRect.zero)
		commonInit()
	}

	private func commonInit() {
		gradient.colors = [AuthenticationUX.backgroundDarkGradientStart.cgColor, AuthenticationUX.backgroundDarkGradientEnd.cgColor]
		gradient.locations = [0.0 , 1.0]
		self.layer.insertSublayer(gradient, at: 0)
		gradient.frame = self.bounds
	}
}
