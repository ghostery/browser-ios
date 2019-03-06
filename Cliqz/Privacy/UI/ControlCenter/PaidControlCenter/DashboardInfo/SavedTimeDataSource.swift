//
//  SavedTimeDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class SavedTimeDataSource: DashboardGeneralInfoDataSource {
	var imageName: String? {
		return "TimeSaved_WidgetDetails"
	}
	
	var count: String {
		return CCWidgetManager.shared.savedTime().0
	}
	
	var unit: String {
		return CCWidgetManager.shared.savedTime().1
	}
	
	var title: String {
		return NSLocalizedString("Time Saved", tableName: "Lumen", comment:"[Lumen->Dashboard] Time Saved widget title")
	}
	
	var description: String {
		return NSLocalizedString("Blocking trackers and ads saves time because pages load faster. Each blocking saves 2.5% loading time on average.", tableName: "Lumen", comment:"[Lumen->Dashboard] time saved widget description")
	}
	
}

#endif
