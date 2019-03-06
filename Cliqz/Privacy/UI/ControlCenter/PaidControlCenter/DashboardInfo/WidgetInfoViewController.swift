//
//  WidgetInfoViewController.swift
//  Client
//
//  Created by Sahakyan on 3/1/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class WidgetInfoViewController: UIViewController {
	
	let closeButton = UIButton()
	let containerView = UIView()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupViews()
		self.setupConstraints()
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return ThemeManager.instance.statusBarStyle
	}

	private func setupViews() {
		self.view.addSubview(closeButton)
		closeButton.setTitle(NSLocalizedString("Close", tableName: "Lumen", comment: "Close button title on dashboard info"), for: .normal)
		closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
		closeButton.backgroundColor = UIColor.clear
		closeButton.setTitleColor(UIColor.lumenTextBlue, for: .normal)
		closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
		
		self.view.addSubview(containerView)
		containerView.backgroundColor = UIColor.clear
		self.view.backgroundColor = UIColor.lumenPurple

	}

	private func setupConstraints() {
		closeButton.snp.makeConstraints { (make) in
			make.top.equalToSuperview().offset(16)
			make.right.equalToSuperview().offset(-7)
		}
		containerView.snp.makeConstraints { (make) in
			make.left.right.bottom.equalToSuperview()
			make.top.equalTo(closeButton.snp.bottom).offset(10)
		}
	}

	@objc private func close() {
		self.dismiss(animated: true, completion: nil)
	}
}

#endif
