//
//  OffrzEmptyView.swift
//  Client
//
//  Created by Sahakyan on 12/27/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

class OffrzEmptyView: UIView {
	private let offrzPresentImageView = UIImageView(image: UIImage(named: "offrzPresent"))
	private let emptyTextLabel = UILabel()

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

	private func setup() {
		self.setupComponents()
		self.setStyles()
		self.layoutComponents()
	}

	private func setupComponents() {
		self.addSubview(emptyTextLabel)
		self.addSubview(offrzPresentImageView)
		emptyTextLabel.text = NSLocalizedString("MyOffrz Empty Description", tableName: "Cliqz", comment: "[MyOffrz] No offers label")
	}

	private func setStyles() {
		emptyTextLabel.textColor = UIColor.white
        emptyTextLabel.applyShadow()
	}

	private func layoutComponents() {
		offrzPresentImageView.snp.remakeConstraints({ (make) in
			make.centerX.equalTo(self)
			make.centerY.equalTo(self).dividedBy(2)
		})
		emptyTextLabel.snp.remakeConstraints({ (make) in
			make.centerX.equalTo(self)
			make.top.equalTo(offrzPresentImageView.snp.bottom).offset(10)
		})
	}
}
