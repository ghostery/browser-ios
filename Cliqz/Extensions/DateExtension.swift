//
//  DateExtension.swift
//  Client
//
//  Created by Mahmoud Adam on 3/13/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

extension Date {
    
    static func getCurrentMillis()-> Double {
        return  Date().timeIntervalSince1970 * 1000.0
    }
    
    func daysSince1970() -> Int {
        return Int(self.timeIntervalSince1970 / 86400.0)
    }
}
