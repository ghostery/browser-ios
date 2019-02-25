//
//  DashboardContextualOnboardingView.swift
//  Client
//
//  Created by Sahakyan on 2/22/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class DashboardContextualOnboardingView: UIView {
	
	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.text = NSLocalizedString("Did you know?", tableName: "Lumen", comment: "[Contextual onboarding] For Dashboard")
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .left
		titleLabel.textColor = UIColor.white
		titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
		titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
		return titleLabel
	}()
	
	lazy var descriptionLabel: UILabel = {
		let textLabel = UILabel()
		textLabel.text = NSLocalizedString("Ultimate protection: Lumen blocks ads and trackers.", tableName: "Lumen", comment: "[Contextual onboarding] For Dashboard")
		textLabel.numberOfLines = 2
		textLabel.adjustsFontSizeToFitWidth = true
		textLabel.minimumScaleFactor = 0.5
		textLabel.textAlignment = .left
		textLabel.textColor = UIColor.white
		textLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		textLabel.lineBreakMode = .byTruncatingTail
		textLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
		return textLabel
	}()

	lazy var imageView: UIImageView = {
		let img = UIImage(named: "arrow_to_dashboard")
		return UIImageView(image: img)
	}()

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	init() {
		super.init(frame: .zero)
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		self.addSubview(imageView)
		imageView.snp.makeConstraints { make in
			make.top.equalToSuperview()
			make.right.equalToSuperview().inset(-10)
		}
		titleLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(3)
			make.left.equalToSuperview()
			make.right.equalTo(imageView.snp.left)
			make.height.equalTo(15)
		}
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom)
			make.left.right.equalToSuperview()
			make.height.equalTo(50)
		}
		self.backgroundColor = UIColor.lumenDeepBlue
		self.isUserInteractionEnabled = false
	}
}
