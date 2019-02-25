//
//  PrivacyContextualOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 2/22/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class PrivacyContextualOnboardingView: UIView {

	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .center
		titleLabel.textColor = UIColor.white
		titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
		titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
		return titleLabel
	}()

	lazy var infoLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.numberOfLines = 2
		textLabel.adjustsFontSizeToFitWidth = true
		textLabel.minimumScaleFactor = 0.5
		textLabel.textAlignment = .center
		textLabel.textColor = UIColor.white
		textLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		textLabel.lineBreakMode = .byTruncatingTail
		textLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
		return textLabel
	}()

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	init(title: String, info: String) {
		super.init(frame: .zero)
		titleLabel.text = title
		infoLabel.text = info
		self.configureViews()
		self.setupConstraints()
	}

	private func configureViews() {
		self.addSubview(titleLabel)
		self.addSubview(infoLabel)
		self.backgroundColor = UIColor.lumenDeepBlue
		self.isUserInteractionEnabled = false
	}

	private func setupConstraints() {
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(3)
			make.left.right.equalToSuperview()
			make.height.equalTo(15)
		}
		infoLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom)
			make.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
	}
}
