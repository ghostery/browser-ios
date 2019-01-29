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
    
    func daysSince(_ date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: self))
        return components.day
    }
    
    func daysUntil(_ date: Date) -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: self), to: calendar.startOfDay(for: date))
        return components.day
    }
    
    func formatDate(dateFormat: String? = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
}
