//
//  GhosteryTab.swift
//  Storage
//
//  Created by Mahmoud Adam on 4/26/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class GhosteryTab {
    let id: Int
    let order: Int
    let url: String
    
    init(_ id: Int, order: Int, url: String) {
        self.id = id
        self.order = order
        self.url = url
    }
}
