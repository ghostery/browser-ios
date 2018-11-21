//
//  EmailTextField.swift
//  Client
//
//  Created by Sahakyan on 11/16/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

class EmailTextField: UITextField {
	
	let padding = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 13)
	
	override open func textRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
	
	override open func editingRect(forBounds bounds: CGRect) -> CGRect {
		return UIEdgeInsetsInsetRect(bounds, padding)
	}
}
