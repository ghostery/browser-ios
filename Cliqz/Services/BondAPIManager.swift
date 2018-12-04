//
//  BondAPIManager.swift
//  Client
//
//  Created by Sahakyan on 11/21/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import BondAPI

class BondAPIManager {
	
	private static let hostName = "api.lumenbrowser.com"
	private static let stagingHostName = "api-staging.lumenbrowser.com"

	private let euBondHandler: BondV1

	static let shared = BondAPIManager()

	init() {
		#if BETA
		euBondHandler = BondV1(host: BondAPIManager.stagingHostName)
		#else
		euBondHandler = BondV1(host: BondAPIManager.hostName)
		#endif
	}

	func currentBondHandler() -> BondV1 {
		return euBondHandler
	}

}
