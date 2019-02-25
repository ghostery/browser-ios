//
//  AdblokingContextualOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 2/22/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class AdblokingContextualOnboardingView: PrivacyContextualOnboardingView {
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	init(blockedAdsCount: Int) {
		let title = NSLocalizedString("Did you know?", tableName: "Lumen", comment: "[Contextual onboarding] For Adblocker")
		let info = String(format: NSLocalizedString("Lumen just blocked %d ads", tableName: "Lumen", comment: "[Contextual onboarding] Adblocker details"), blockedAdsCount)
		super.init(title: title, info: info)
	}
}
