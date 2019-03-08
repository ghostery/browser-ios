//
//  DashboardListInfoDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

protocol DashboardListInfoDataSource: class {
	
	var imageName: String { get }
	var count: String { get }
	var headerTitle: String { get }
	var headerDescription: String { get }
	var sectionHeaderTitle: String { get }
	var listCount: Int { get }
	func listItemTitle(forIndex index: Int) -> String

}

#endif
