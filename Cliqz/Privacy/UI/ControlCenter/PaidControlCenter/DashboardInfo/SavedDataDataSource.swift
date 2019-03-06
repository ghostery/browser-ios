//
//  SavedDataDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
#if PAID

import Foundation

class SavedDataDataSource: DashboardGeneralInfoDataSource {

	var imageName: String? {
		return "DataSaved_WidgetDetails"
	}
	
	var count: String {
		return CCWidgetManager.shared.dataSaved().0
	}
	
	var unit: String {
		return CCWidgetManager.shared.dataSaved().1
	}
	
	var title: String {
		return NSLocalizedString("Data Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}
	
	var description: String {
		return NSLocalizedString("Blocking trackers and ads saves data for your monthly data package to last longer.", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}
	
}

#endif
