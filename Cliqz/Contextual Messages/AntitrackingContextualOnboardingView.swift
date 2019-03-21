//
//  AntitrackingContextualOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 2/22/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class AntitrackingContextualOnboardingView: PrivacyContextualOnboardingView {
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	init(trackerName: String) {
		let title = NSLocalizedString("Well protected!", tableName: "Lumen", comment: "[Contextual onboarding] For Antitracking")
		let info = String(format: NSLocalizedString("Lumen just blocked %@ from accessing your data.", tableName: "Lumen", comment: "[Contextual onboarding] Antitracking details"), trackerName)
		super.init(title: title, info: info)
        ContextualMessagesViewModel.shared.contextualMessageShown(.antiTracking(trackerName))
	}
}
