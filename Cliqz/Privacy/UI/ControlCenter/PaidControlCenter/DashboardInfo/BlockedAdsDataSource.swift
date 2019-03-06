//
//  BlockedAdsDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#if PAID

import Foundation

class BlockedAdsDataSource: DashboardListInfoDataSource {
	var imageName: String {
		return "BlockedAds_WidgetDetails"
	}

	var count: String {
		return CCWidgetManager.shared.dataSaved().0
	}

	var headerTitle: String {
		return NSLocalizedString("Ad Blocker", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var headerDescription: String {
		return NSLocalizedString("Lumen removed ads by these providers.", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var sectionHeaderTitle: String {
		return NSLocalizedString("Removed ad providers", tableName: "Lumen", comment:"[Lumen->Dashboard] Data Volume Saved widget title")
	}

	var listCount: Int {
		return 0
	}

	var listItemTitle: String {
		return ""
	}
}

#endif
