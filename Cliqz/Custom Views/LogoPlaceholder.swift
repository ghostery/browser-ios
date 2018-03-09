//
//  LogoPlaceholder.swift
//  Client
//
//  Created by Sahakyan on 7/3/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import SnapKit

class LogoPlaceholder: UIView {

	init(logoInfo: LogoInfo) {
		super.init(frame: CGRect.zero)
		if let color = logoInfo.color {
			self.backgroundColor = UIColor(colorString: color)
		} else {
			self.backgroundColor = UIColor.black
		}
		let l = UILabel()
		l.textColor = UIColor.white
		if let title = logoInfo.prefix {
			l.text = title
		} else {
			l.text = "N/A"
		}
		let fontSize = logoInfo.fontSize ?? 15
		l.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
		self.addSubview(l)
		l.snp.makeConstraints({ (make) in
			make.center.equalTo(self)
		})
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
