//
//  WelcomeView.swift
//  Client
//
//  Created by Sahakyan on 2/21/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class WelcomeView: UIView {

	lazy var imageView: UIImageView = {
		let img = UIImage(named: "welcomeLogo")
		return UIImageView(image: img)
	}()

	lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.text = NSLocalizedString("Welcome to Lumen!", tableName: "Lumen", comment: "[Start Page] Welcome view title")
		titleLabel.numberOfLines = 1
		titleLabel.textAlignment = .center
		titleLabel.textColor = UIColor.white
		titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
		titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
		return titleLabel
	}()
	
	lazy var descriptionLabel: UILabel = {
		let textLabel = UILabel()
        textLabel.text = NSLocalizedString("Ultimate protection online.\nIntegrated VPN for protection on public Wi-Fi.", tableName: "Lumen", comment: "[Start Page] Welcome view description")
		textLabel.numberOfLines = 2
		textLabel.adjustsFontSizeToFitWidth = true
		textLabel.minimumScaleFactor = 0.5
		textLabel.textAlignment = .center
		textLabel.textColor = UIColor.white
		textLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
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
	
	init() {
		super.init(frame: .zero)
		self.addSubview(imageView)
		self.addSubview(titleLabel)
		self.addSubview(descriptionLabel)
		imageView.snp.makeConstraints { make in
			make.top.equalTo(self)
			make.centerX.equalToSuperview()
		}
		titleLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(15)
			make.left.right.equalToSuperview()
			make.height.equalTo(30)
		}
		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(10)
			make.left.right.equalToSuperview()
			make.height.equalTo(50)
		}
		self.isUserInteractionEnabled = false
		descriptionLabel.isHidden = true
	}

}
