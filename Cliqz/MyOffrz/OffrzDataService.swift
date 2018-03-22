//
//  OffrzAPI.swift
//  Client
//
//  Created by Sahakyan on 12/5/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Offr {
	let uid: String?
	let title: String?
	let description: String?
	let url: String?
	let logoURL: String?
	let code: String?
	let actionTitle: String?
	let conditions: String?
	let startDate: Date?
	let endDate: Date?
	var isSeen = false
}

class OffrzDataService {
	var lastOffrz = [Offr]()

	private var validityStart: Date?
	private var validityEnd: Date?

	private static let APIURL = "https://offers-api.cliqz.com/api/v1/loadsubtriggers?parent_id=mobile-root&t_eng_ver=1" //  "http://10.1.21.104/api/v1/loadsubtriggers?parent_id=mobile-root&t_eng_ver=1"

	static let shared = OffrzDataService()

	func getMyOffrz(completionHandler: @escaping ([Offr], Error?) -> Void) {
		self.loadData(successHandler: {
			print("Hello1")
			completionHandler(self.lastOffrz, nil)
		}, failureHandler: { (e) in
			completionHandler([], nil)
			print("Error : \(e)")
		})
	}

	func isLastOffrValid() -> Bool {
		return self.validityStart != nil && self.validityEnd != nil && !self.isExpiredOffr()
	}

	private func loadData(successHandler: @escaping () -> Void, failureHandler: @escaping (Error?) -> Void) {
		Alamofire.request(OffrzDataService.APIURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
			if response.result.isSuccess {
				let json = JSON(response.result.value ?? "")
				if let data = json.array {
					self.lastOffrz = [Offr]()
					for o in data {
						if let offr = o.dictionary {
							var startDate: Date?
							var endDate: Date?
							var uid: String? = offr["trigger_uid"]?.string
							if let validity = offr["validity"]?.array {
								if validity.count >= 2 {
									startDate = Date(timeIntervalSince1970: validity[0].doubleValue)
									endDate = Date(timeIntervalSince1970: validity[1].doubleValue)
								}
							}
							if let actions = offr["actions"]?.array {
								for action in actions {
									if let actionType = action.array, actionType.count > 1,
										let type = actionType[0].string,
										type == "$show_offer",
										let showOffer = actionType[1].array,
										showOffer.count > 1,
										let offrInfo = showOffer[1].dictionary,
										let uiInfo = offrInfo["ui_info"]?.dictionary,
										let details = uiInfo["template_data"]?.dictionary {
										var actionTitle: String?
										var url: String?
										if let callToAction = details["call_to_action"]?.dictionary {
											actionTitle = callToAction["text"]?.string
											url = callToAction["url"]?.string
										}
										self.lastOffrz.append(Offr(uid: uid, title: details["title"]?.string, description: details["desc"]?.string, url: url, logoURL: details["logo_url"]?.string, code: details["code"]?.string,  actionTitle: actionTitle, conditions: details["conditions"]?.string, startDate: startDate, endDate: endDate, isSeen: false))
										}
								}
							}
						}
					}
					successHandler()
					return
				}
				failureHandler(nil) // TODO proper Error
			} else {
				failureHandler(response.error) // TODO proper Error
			}
		}
	}

	private func isExpiredOffr() -> Bool {
		let now =  Date()
		if let start = self.validityStart,
			let end = self.validityEnd {
			return start > now || end < now
		}
		return false
	}
}
