//
//  OffrzEmptyView.swift
//  Client
//
//  Created by Sahakyan on 12/27/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

class OffrzEmptyView: UIView {
    private let emptyTitleLabel = UILabel()
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
        self.addSubview(emptyTitleLabel)
		self.addSubview(emptyTextLabel)
        if SettingsPrefs.shared.getRegionPref() == "DE" {
            emptyTitleLabel.text = NSLocalizedString("Seems like we don't have any offers", tableName: "Cliqz", comment: "[MyOffrz] No offers title label for DE")
            emptyTextLabel.text = NSLocalizedString("But we'll keep looking for you and add them here as soon as we have one", tableName: "Cliqz", comment: "[MyOffrz] No offers text label for DE")
        } else {
            emptyTitleLabel.text = NSLocalizedString("We don't have any offers for your country yet", tableName: "Cliqz", comment: "[MyOffrz] No offers title label")
            emptyTextLabel.text = NSLocalizedString("But stay tuned to receive attractive discounts and bargains in the future", tableName: "Cliqz", comment: "[MyOffrz] No offers text label")
        }
        
        
	}

	private func setStyles() {
        emptyTitleLabel.numberOfLines = 2
        emptyTitleLabel.textAlignment = .center
        emptyTitleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        emptyTitleLabel.textColor = UIColor.white
        emptyTitleLabel.applyShadow()
        
        emptyTextLabel.numberOfLines = 2
        emptyTextLabel.textAlignment = .center
		emptyTextLabel.textColor = UIColor.white
        emptyTextLabel.applyShadow()
	}

	private func layoutComponents() {
		emptyTitleLabel.snp.remakeConstraints({ (make) in
			make.centerX.equalTo(self)
			make.centerY.equalTo(self).dividedBy(2)
            make.width.equalTo(self).dividedBy(1.2)
		})
		emptyTextLabel.snp.remakeConstraints({ (make) in
			make.centerX.equalTo(self)
            make.width.equalTo(self).dividedBy(1.2)
			make.top.equalTo(emptyTitleLabel.snp.bottom).offset(10)
		})
	}
}
