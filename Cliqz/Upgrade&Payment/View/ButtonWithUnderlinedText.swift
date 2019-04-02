//
//  ButtonWithUnderlinedText.swift
//  Client
//
//  Created by Sahakyan on 1/29/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class ButtonWithUnderlinedText: UIButton {
	
	enum PositionType {
		case bottom
		case next
	}

	private let startText: (String, UIColor)
	private let underlinedText: (String, UIColor)
	private let position: PositionType
    private let telemetryView: String?

    init(startText: (String, UIColor), underlinedText: (String, UIColor), position: PositionType = .next, view: String? = nil) {
		self.startText = startText
		self.underlinedText = underlinedText
		self.position = position
        self.telemetryView = view
		super.init(frame: .zero)
		self.titleLabel?.numberOfLines = 0
		self.titleLabel?.textAlignment = .center
		self.setAttributedTitle(self.generateTitle(), for: .normal)
        self.addTarget(self, action: #selector(logClickAction), for: .touchUpInside)
        if let view = self.telemetryView {
            LegacyTelemetryHelper.logMessage(action: "show", topic: "upgrade", style: "footer", view: view)
        }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func updateViewState(isEnabled: Bool) {
		if isEnabled {
			self.setAttributedTitle(self.generateTitle(), for: .normal)
			self.isEnabled = true
		} else {
			self.setAttributedTitle(self.generateTitle(isEnabled: false), for: .normal)
			self.isEnabled = false
		}
	}

	private func generateTitle(isEnabled state: Bool = true) -> NSAttributedString {
		var title: NSMutableAttributedString!
		let underlinedFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium),
										NSAttributedStringKey.underlineStyle: NSNumber(value: 1),
										NSAttributedStringKey.foregroundColor: state ? self.underlinedText.1 : UIColor.lumenDisabled]
		if let range = startText.0.range(of: startText.0), range.lowerBound == startText.0.startIndex {
			let normalFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: state ? startText.1 : UIColor.lumenDisabled]
			if position == .next {
				title = NSMutableAttributedString(string:startText.0 + " ", attributes:normalFontAttributes)
			} else {
				title = NSMutableAttributedString(string:startText.0 + "\n", attributes:normalFontAttributes)
			}
			title.append(NSAttributedString(string: underlinedText.0, attributes:underlinedFontAttributes))
		} else {
			title = NSMutableAttributedString(string:underlinedText.0, attributes:underlinedFontAttributes)
		}
		return title
	}
    
    @objc func logClickAction() {
        if let view = self.telemetryView {
            LegacyTelemetryHelper.logMessage(action: "click", topic: "upgrade", style: "footer", view: view, target: "upgrade")
        }
    }
}
