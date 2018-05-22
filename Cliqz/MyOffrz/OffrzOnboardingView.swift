//
//  OffrzOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 12/27/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

enum OffrzOnboardingActions {
	case hide
	case learnMore
}

typealias OffrzOnboardingActionHandler = () -> Void

class OffrzOnboardingView: UIView {
	private let hideButton = UIButton(type: .custom)
	private let descriptionLabel = UILabel()
	private let moreButton = UIButton(type: .custom)
	private let offrzPresentImageView = UIImageView(image: UIImage(named: "offrzPresent"))

	private var actionHandlers = [OffrzOnboardingActions: OffrzOnboardingActionHandler]()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setup()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setup()
	}

	init() {
		super.init(frame: CGRect.zero)
		self.setup()
	}

	override func updateConstraints() {
		super.updateConstraints()
		self.layoutComponents()
	}

	func addActionHandler(_ action: OffrzOnboardingActions, handler: @escaping OffrzOnboardingActionHandler) {
		self.actionHandlers[action] = handler
	}

	private func setup() {
		self.setupComponents()
		self.setStyles()
		self.layoutComponents()
	}

	private func setupComponents() {
		self.addSubview(offrzPresentImageView)
		
        hideButton.setImage(UIImage.templateImageNamed("tab_close"), for: UIControlState())
		hideButton.addTarget(self, action: #selector(hideOnboardingView) , for: .touchUpInside)
		self.addSubview(hideButton)
		
		descriptionLabel.text = NSLocalizedString("MyOffrz Onboarding", tableName: "Cliqz", comment: "[MyOffrz] MyOffrz description")
		self.addSubview(descriptionLabel)
		
		moreButton.setTitle(NSLocalizedString("LEARN MORE", tableName: "Cliqz", comment: "[MyOffrz] Learn more button title"), for: .normal)
		moreButton.addTarget(self, action: #selector(openLearnMore), for: .touchUpInside)
		self.addSubview(moreButton)
	}

	private func setStyles() {
		//self.backgroundColor = UIColor(colorString: "ABD8EA")

        descriptionLabel.textColor = .white
        descriptionLabel.applyShadow()
		descriptionLabel.textAlignment = .center
		descriptionLabel.numberOfLines = 2

		moreButton.setTitleColor(UIColor.cliqzBluePrimary, for: .normal)
        hideButton.tintColor = UIColor.cliqzBluePrimary
	}

	private func layoutComponents() {
		hideButton.snp.remakeConstraints { (make) in
			make.top.right.equalTo(self).inset(10)
			make.height.width.equalTo(25)
		}
		offrzPresentImageView.snp.remakeConstraints { (make) in
			make.centerX.equalTo(self)
			make.top.equalTo(self).inset(10)
		}
		descriptionLabel.snp.remakeConstraints { (make) in
			make.right.left.equalTo(self).inset(25)
			make.top.equalTo(offrzPresentImageView.snp.bottom).offset(10)
		}
		moreButton.snp.remakeConstraints { (make) in
			make.centerX.equalTo(self)
			make.bottom.equalTo(self)
		}
	}

	@objc
	private func openLearnMore() {
		if let action = self.actionHandlers[.learnMore] {
			action()
		}
	}

	@objc
	private func hideOnboardingView() {
		if let action = self.actionHandlers[.hide] {
			action()
		}
	}
}
