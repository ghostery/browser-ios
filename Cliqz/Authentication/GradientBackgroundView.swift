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

    init(colors: [CGColor], locations: [NSNumber]) {
		super.init(frame: CGRect.zero)
        gradient.colors = colors
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        gradient.frame = self.bounds
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        gradient.frame = self.bounds
        super.layoutSubviews()
    }
}

class LoginGradientView: GradientBackgroundView {
    
    override init(colors: [CGColor], locations: [NSNumber]) {
        fatalError("Use the initializer below")
    }
    
    init() {
        let colors = [AuthenticationUX.backgroundDarkGradientStart.cgColor, AuthenticationUX.backgroundDarkGradientEnd.cgColor]
        super.init(colors: colors, locations: [0.0, 1.0])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BrowserGradientView: GradientBackgroundView {
    
    override init(colors: [CGColor], locations: [NSNumber]) {
        fatalError("Use the initializer below")
    }
    
    init() {
        let (colors, locations) = Lumen.Browser.backgroundGradient(lumenTheme)
        super.init(colors: colors, locations: locations)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
