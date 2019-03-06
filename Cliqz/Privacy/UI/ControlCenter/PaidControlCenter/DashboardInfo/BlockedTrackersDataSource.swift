//
//  BlockedTrackersDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class BlockedTrackersDataSource: DashboardListInfoDataSource {
	var imageName: String {
		return "BlockedTrackers_WidgetDetails"
	}
	
	var count: String {
		return CCWidgetManager.shared.dataSaved().0
	}
	
	var headerTitle: String {
		return NSLocalizedString("Tracker Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}
	
	var headerDescription: String {
		return NSLocalizedString("Lumen prevented these company from collecting data about you.", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var sectionHeaderTitle: String {
		return NSLocalizedString("Blocked trackers", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var listCount: Int {
		return 0
	}
	
	var listItemTitle: String {
		return ""
	}
}
