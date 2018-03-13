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
}
