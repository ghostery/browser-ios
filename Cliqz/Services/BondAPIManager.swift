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
	
	private static let hostName = "ambassador.dev.k8s.eu-central-1.clyqz.com"
	private let euBondHandler = BondV1(host: BondAPIManager.hostName)

	static let shared = BondAPIManager()

	func currentBondHandler() -> BondV1 {
		return euBondHandler
	}

}
