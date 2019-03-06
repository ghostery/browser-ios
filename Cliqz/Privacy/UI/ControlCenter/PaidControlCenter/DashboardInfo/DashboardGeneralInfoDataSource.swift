//
//  DashboardGeneralInfoDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

protocol DashboardGeneralInfoDataSource: class {

	var imageName: String? { get }
	var count: String { get }
	var unit: String { get }
	var title: String { get }
	var description: String { get }
}

#endif
