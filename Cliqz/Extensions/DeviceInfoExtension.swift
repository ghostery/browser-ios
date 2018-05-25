//
//  DeviceInfoExtension.swift
//  Shared
//
//  Created by Sahakyan on 5/24/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation

extension DeviceInfo {

	// Cliqz: added hasWwanConnectivity() method to check if the device is connected via wwan
	open class func hasWwanConnectivity() -> Bool {
		let status = Reach().connectionStatus()
		switch status {
		case .online(.wwan):
			return true
		default:
			return false
		}
	}

	open class func hasWiFiConnectivity() -> Bool {
		let status = Reach().connectionStatus()
		switch status {
		case .online(.wiFi):
			return true
		default:
			return false
		}
	}
}
