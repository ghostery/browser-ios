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

	init(startText: (String, UIColor), underlinedText: (String, UIColor), position: PositionType = .next) {
		self.startText = startText
		self.underlinedText = underlinedText
		self.position = position
		super.init(frame: .zero)
		
		self.setAttributedTitle(self.generateTitle(), for: .normal)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func generateTitle() -> NSAttributedString {
		self.titleLabel?.numberOfLines = 0
		self.titleLabel?.textAlignment = .center
		var title: NSMutableAttributedString!
		let underlinedFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium),
										NSAttributedStringKey.underlineStyle: NSNumber(value: 1),
										NSAttributedStringKey.foregroundColor: self.underlinedText.1]
		if let range = startText.0.range(of: startText.0), range.lowerBound == startText.0.startIndex {
			let normalFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: startText.1]
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
}
