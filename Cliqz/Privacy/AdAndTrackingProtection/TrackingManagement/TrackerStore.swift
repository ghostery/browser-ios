//
//  TrackerStore.swift
//  BrowserCore
//
//  Created by Tim Palade on 3/19/18.
//  Copyright © 2018 Tim Palade. All rights reserved.
//

import UIKit

class TrackerStore: PersistentSet<Int> {
    
    static let shared = TrackerStore()
    
    init() {
        super.init(id: "TrackerStore")
    }
}



