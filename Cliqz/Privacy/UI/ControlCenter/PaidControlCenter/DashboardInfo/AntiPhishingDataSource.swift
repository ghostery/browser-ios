//
//  AntiPhishingDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/4/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class AntiPhishingDataSource: DashboardGeneralInfoDataSource {

	var imageName: String? {
		return "Antiphishing_WidgetDetails"
	}

	var count: String {
		return CCWidgetManager.shared.pagesChecked() + " " + NSLocalizedString("web sites checked", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing Protection widget detailed info")
	}

	var unit: String {
		return ""
	}

	var title: String {
		return NSLocalizedString("Phishing Protection", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing Protection widget title")
	}

	var description: String {
		return NSLocalizedString("Lumen warns you about suspicious and counterfeit web sites trying to steal personal data.", tableName: "Lumen", comment:"[Lumen->Dashboard] Phishing protection widget description")
	}

}
