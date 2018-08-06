//
//  StringExtension.swift
//  Client
//
//  Created by Sahakyan on 2/26/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation

extension String {

	func escapeURL() -> String? {
		if self.contains("%") { // String already escaped
			return self
		}
		return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
	}

	var boolValue: Bool {
		return NSString(string: self).boolValue
	}

	func trim() -> String {
		let newString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		return newString
	}

	func removeWhitespaces() -> String {
		return self.replace(" ", replacement: "")
	}

	func replace(_ string:String, replacement:String) -> String {
		return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
	}
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attrs = [NSAttributedStringKey.font: font]
        let boundingRect = NSString(string: self).boundingRect(with: size,
                                                               options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                               attributes: attrs, context: nil)
        return boundingRect.height
    }
    
    func md5() -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        if let data = self.data(using: String.Encoding.utf8) {
            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }

}
