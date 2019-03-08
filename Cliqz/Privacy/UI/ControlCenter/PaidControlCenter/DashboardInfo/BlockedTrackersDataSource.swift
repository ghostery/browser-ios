//
//  BlockedTrackersDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class BlockedTrackersDataSource: DashboardListInfoDataSource {
	var imageName: String {
		return "BlockedTrackers_WidgetDetails"
	}
	
	var count: String {
		return String(CCWidgetManager.shared.companies())
	}
	
	var headerTitle: String {
		return NSLocalizedString("Tracker Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}
	
	var headerDescription: String {
		return NSLocalizedString("Lumen prevented these companies from collecting data about you.", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var sectionHeaderTitle: String {
		return NSLocalizedString("Blocked trackers", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var listCount: Int {
		return trackersList.count
	}
	
	func listItemTitle(forIndex index: Int) -> String {
		return trackersList[index]
	}

	private var trackersList = CCWidgetManager.shared.trackersList()

}

#endif
