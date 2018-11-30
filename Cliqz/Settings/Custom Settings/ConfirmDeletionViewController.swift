//
//  ConfirmDeletionViewController.swift
//  Client
//
//  Created by Sahakyan on 11/29/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class ConfirmDeletionViewController: UIViewController {
	let titleLabel = UILabel()
	let descriptionLabel = UILabel()
	let openEmailButton = UIButton()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		self.titleLabel.snp.remakeConstraints { (make) in
			make.centerX.equalToSuperview()
			make.centerY.equalToSuperview()
			make.height.equalTo(24)
		}
		self.descriptionLabel.snp.remakeConstraints { (make) in
			make.left.equalToSuperview().offset(29)
			make.right.equalToSuperview().offset(-29)
			make.top.equalTo(self.titleLabel.snp.bottom).offset(40)
			make.height.equalTo(60)
		}
		self.openEmailButton.snp.remakeConstraints { (make) in
			make.left.equalToSuperview().offset(29)
			make.right.equalToSuperview().offset(-29)
			make.top.equalTo(descriptionLabel.snp.bottom).offset(63)
			make.height.equalTo(33)
		}
	}
	
	private func setupViews() {
		self.view.addSubview(self.titleLabel)
		self.view.addSubview(self.descriptionLabel)
		self.view.addSubview(self.openEmailButton)
		
		self.titleLabel.text = NSLocalizedString("Confirm account deletion", tableName: "Cliqz", comment: "")
		self.titleLabel.textAlignment = .center
		self.titleLabel.textColor = UIColor.black
		self.titleLabel.font = AuthenticationUX.titleFont
		
		self.descriptionLabel.text = NSLocalizedString("We are sorry that you are leaving. Please check your inbox and open the confirmation link to complete account deletion.", tableName: "Cliqz", comment: "")
		self.descriptionLabel.textAlignment = .center
		self.descriptionLabel.textColor = UIColor.black
		self.descriptionLabel.font = AuthenticationUX.subtitleFont
		self.descriptionLabel.numberOfLines = 3

		self.openEmailButton.setTitle(NSLocalizedString("Open Mail App", tableName: "Cliqz", comment: ""), for: .normal)
		self.openEmailButton.backgroundColor = AuthenticationUX.blue
		self.openEmailButton.layer.cornerRadius = AuthenticationUX.cornerRadius
		self.openEmailButton.layer.borderWidth = 0
		self.openEmailButton.layer.masksToBounds = true
		self.openEmailButton.addTarget(self, action: #selector(openEmailApp), for: .touchUpInside)
	}

	@objc
	private func openEmailApp() {
		if let url = URL(string: "message://"),
			UIApplication.shared.canOpenURL(url) {
			UIApplication.shared.open(url)
		}
	}
}
