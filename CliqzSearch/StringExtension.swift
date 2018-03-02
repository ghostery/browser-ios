//
//  StringExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 11/9/15.
//  Copyright © 2015 Cliqz. All rights reserved.
//

import Foundation
import Shared

extension String {
    
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
    
    
    func trim() -> String {
        let newString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return newString
    }
    
    static func generateRandomString(_ length: Int, alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") -> String {
        var randomString = ""
        
        let rangeLength = UInt32 (alphabet.characters.count)
        
        for _ in 0 ..< length {
            let randomIndex = Int(arc4random_uniform(rangeLength))
            randomString.append(alphabet[alphabet.characters.index(alphabet.startIndex, offsetBy: randomIndex)])
        }
        
        return String(randomString)
    }
    
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhitespaces() -> String {
        return self.replace(" ", replacement: "")
    }
    
    func escapeURL() -> String {
        if self.contains("%") { // String already escaped
            return self
        } else {
            let allowedCharacterSet = NSMutableCharacterSet()
            allowedCharacterSet.formUnion(with: CharacterSet.urlQueryAllowed)            
            return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)!
        }
    }
	
	// Cliqz added extra URL encoding methods because stringByAddingPercentEncodingWithAllowedCharacters doesn't encodes &
	func encodeURL() -> String {
		return CFURLCreateStringByAddingPercentEscapes(nil,
			self as CFString,
			nil,
			String("!*'\"();:@&=+$,/?%#[]% ") as CFString, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) as String
	}
    
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let attrs = [NSFontAttributeName: font]
        let boundingRect = NSString(string: self).boundingRect(with: size,
                                                                       options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                       attributes: attrs, context: nil)
        return boundingRect.height
    }

}
