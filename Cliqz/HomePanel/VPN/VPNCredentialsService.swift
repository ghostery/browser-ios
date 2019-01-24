//
//  VPNCredentialsService.swift
//  Client
//
//  Created by Sahakyan on 1/23/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct VPNData {
	let country: String
	let username: String
	let password: String
	let secret: String
	let serverIP: String
	let port: String
}

class VPNCredentialsService {
	
	private static let APIKey = "LumenAPIKey"

	class func getVPNCredentials(completion: @escaping ([VPNData]) -> Void) {
		guard let apiKey = Bundle.main.object(forInfoDictionaryKey: APIKey) as? String, !apiKey.isEmpty else {
			print("API Key is not available in Info.plist")
			return
		}

		let params = ["user": "lumen@cliqz.com",
					  "password": "123pass",
					  "token": "token"]
		let header = ["x-api-key": apiKey]
		var result = [VPNData]()
		Alamofire.request("https://nae1kxj155.execute-api.eu-central-1.amazonaws.com/default/bond-vpn", method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
			if response.result.isSuccess {
				let json = JSON(response.result.value ?? "")
				if let vpnCreds = json.array {
					for cred in vpnCreds {
						if let c = cred.dictionary,
							let country = c.keys.first,
							let data = c[country]?.dictionary,
							let username = data["Username"]?.string,
							let password = data["Password"]?.string,
							let secret = data["IPSecSecret"]?.string,
							let ip = data["ServerIP"]?.string,
							let port = data["ServerPort"]?.string {
							result.append(VPNData(country: country, username: username, password: password, secret: secret, serverIP: ip, port: port))
						}
					}
				}
			} else {
				print(response.error) // TODO proper Error
			}
			completion(result)
		}

		/*
		Alamofire.request("http://c.betrad.com/mobile/ghostery-ios-can-access").responseData { (response) in
			if response.value?.count == 0 {
				DispatchQueue.main.async {
					self.updateImageStatus(self.WifiProtectedStatusImage, isOn: true)
					self.updateImageStatus(self.configStatusImage, isOn: true)
				}
			} else {
				DispatchQueue.main.async {
					self.updateImageStatus(self.WifiProtectedStatusImage, isOn: false)
					self.updateImageStatus(self.configStatusImage, isOn: false)
				}
			}
		}*/

	}
}
