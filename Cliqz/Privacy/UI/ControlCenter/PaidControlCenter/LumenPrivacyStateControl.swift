//
//  LumenPrivacyStateControl.swift
//  Client
//
//  Created by Sahakyan on 2/26/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class LumenPrivacyStateControl: UIControl {
	
	private let title = UILabel()
	private let privacySwitch = UISwitch()

	init() {
		super.init(frame: CGRect.zero)
		self.backgroundColor = UIColor.clear
		self.setupTitle()
		self.setupSwitch()
		self.setupConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControlEvents) {
		self.privacySwitch.addTarget(target, action: action, for: controlEvents)
	}

	func setState(isOn: Bool) {
		self.privacySwitch.isOn = isOn
	}

	private func setupTitle() {
		title.text = NSLocalizedString("Ultimate Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] ")
		title.backgroundColor = UIColor.clear
		title.font = UIFont.systemFont(ofSize: 17, weight: .regular)
		title.textColor = UIColor.white
		self.addSubview(title)
	}

	private func setupSwitch() {
		self.privacySwitch.onTintColor = UIColor.lumenBrightBlue
		self.addSubview(self.privacySwitch)
	}

	private func setupConstraints() {
		title.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.left.equalToSuperview().offset(15)
			make.height.equalTo(20)
		}
		privacySwitch.snp.makeConstraints { (make) in
			make.centerY.equalToSuperview()
			make.right.equalToSuperview().inset(19)
		}
	}
}

#endif
