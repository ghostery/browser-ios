//
//  LumenFreshtabViewController.swift
//  Client
//
//  Created by Sahakyan on 2/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

struct LumenFreshtabUI {
	static let mainTextColor = UIColor(colorString: "7C90D1")
}

class LumenFreshtabViewController: FreshtabViewController {

	private var infoView: UIView?

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		setupConstraints()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		newsViewController.view.isHidden = true
	}

	private func setupViews() {
		let type = SubscriptionController.shared.getCurrentSubscription()
		switch (type) {
		case .limited:
			break
				// do something
		case .trial:
			let days = type.trialRemainingDays() ?? -1
			if days > 7 {
				let title = String(format: NSLocalizedString("%d more days left in trial", tableName: "Lumen", comment: "Trial days left title"), days)
				let action = NSLocalizedString("UPGRADE", tableName: "Lumen", comment: "Upgrade action")
				let btn = ButtonWithUnderlinedText(startText: (title, LumenFreshtabUI.mainTextColor), underlinedText: (action, UIColor.lumenBrightBlue), position: .bottom)
				btn.addTarget(self, action: #selector(upgrade), for: .touchUpInside)
				infoView = btn
				self.view.addSubview(btn)
			} else if days >= 0 {
				
			} else {
				// TODO: invalid state
			}
		default:
			break
		}
	}

	@objc
	private func upgrade() {
		
	}

	private func setupConstraints() {
		if let view1st7Days = self.infoView as? UIButton {
			view1st7Days.snp.makeConstraints { (make) in
				make.left.right.bottom.equalToSuperview()
				make.height.equalTo(50)
			}
			self.scrollView.snp.remakeConstraints({ (make) in
				make.top.left.right.equalToSuperview()
				make.bottom.equalTo(view1st7Days.snp.top)
			})
		}
	}
}
