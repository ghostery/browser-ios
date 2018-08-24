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

struct RegionTrigger {
    let country: String
    let intent: String
}

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
    
    private static let CONFIG_URL = "https://offers-api.cliqz.com/api/v1/loadsubtriggers?parent_id=root&t_eng_ver=22&channel=mobile-ghostery"
    private static let API_URL = "https://offers-api.cliqz.com/api/v1/offers?t_eng_ver=22&channel=mobile-ghostery&intent_name="
    
	static let shared = OffrzDataService()

    func getMyOffrz(region: String, completionHandler: @escaping ([Offr], Error?) -> Void) {
        self.loadTriggers(successHandler: { (regionTriggers) in
            
            var found = false
            for regionTrigger in regionTriggers {
                if regionTrigger.country.lowercased() == region.lowercased() {
                    self.loadData(intent: regionTrigger.intent, successHandler: {
                        found = true
                        completionHandler(self.lastOffrz, nil)
                    }, failureHandler: { (e) in
                        completionHandler([], nil)
                        print("Error : \(e.debugDescription)")
                    })
                    break
                }
            }
            if !found {
                completionHandler([], nil)
            }
        }) { (error) in
            completionHandler([], nil)
            print("Error : \(error.debugDescription)")
        }
	}
    
    private func loadData(intent: String, successHandler: @escaping () -> Void, failureHandler: @escaping (Error?) -> Void) {
        guard let url = "\(OffrzDataService.API_URL)\(intent)".escapeURL() else { return }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
           
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? "")
                if let offers = json.array {
                    self.lastOffrz.removeAll()
                    for offerData in offers {
                        if let offer = self.createOffer(offerData.dictionary) {
                            self.lastOffrz.append(offer)
                        }
                    }
                }
                successHandler()
            } else {
                failureHandler(response.error) // TODO proper Error
            }
        }
	}
    /*
     Offer format
     ============
     {
         "offer_id": "mobile1_TG1_O1_V1",
         "ui_info": {
            "template_data": {
                "benefit": "Benefit",
                "call_to_action": {
                    "target": "",
                    "text": "CLICK ME",
                    "url": "action_url"
                },
                "code": "coupon",
                "conditions": "new users only",
                "desc": "Some description",
                "headline": "Title",
                "logo_class": "square",
                "logo_url": "logo_url",
                "picture_url": "picture_url",
                "title": "Title",
                "validity": 1535752740
            },
            "template_name": "ticket_template"
         }
     }
     */
    private func createOffer(_ offer: [String: SwiftyJSON.JSON]?) -> Offr? {
        guard let offer = offer else  { return nil }
        
        let startDate = Date()
        let uid = offer["offer_id"]?.stringValue
        
        if let uiInfo = offer["ui_info"]?.dictionary,
            let templateData = uiInfo["template_data"]?.dictionary,
            let callToAction = templateData["call_to_action"]?.dictionary,
            let validity = templateData["validity"] {
            
            let title = templateData["title"]?.stringValue
            let description = templateData["desc"]?.stringValue
            let code = templateData["code"]?.stringValue
            let logoURL = templateData["logo_url"]?.stringValue
            let endDate = Date(timeIntervalSince1970: validity.doubleValue)
            let conditions = templateData["conditions"]?.stringValue
            let url = callToAction["url"]?.string
            let actionTitle = callToAction["text"]?.string
            
            return Offr(uid: uid, title: title, description: description, url: url, logoURL: logoURL, code: code, actionTitle: actionTitle, conditions: conditions, startDate: startDate, endDate: endDate, isSeen: false)
        }
        return nil
    }
}

//MARK:- Triggers
extension OffrzDataService {
    
    /*
     Trigger format
     ==============
     {
        "condition":
        [
            "$and",
            [
                [
                "$if_pref",
                    [
                        "config_location",
                        "de"
                    ]
                ],
                [
                    "$or",
                    [
                        [
                        "$is_category_active",
                            [
                                {
                                    "catName": "tempcat_mobile1_TG1"
                                }
                            ]
                        ]
                    ]
                ]
            ]
        ],
        "actions":
        [
            [
                "$activate_intent",
                [
                    {
                        "durationSecs": 86400,
                        "name": "tempcat_mobile1_TG1"
                    }
                ]
            ]
        ]
     }
     */
    fileprivate func loadTriggers(successHandler: @escaping ([RegionTrigger]) -> Void, failureHandler: @escaping (Error?) -> Void) {
        Alamofire.request(OffrzDataService.CONFIG_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            
            if response.result.isSuccess {
                let json = JSON(response.result.value ?? "")
                let regionTriggers = self.getRegionTriggers(json.array)
                successHandler(regionTriggers)
                
            } else {
                failureHandler(response.error)
            }
        }
    }
    
    fileprivate func getRegionTriggers(_ triggers: [SwiftyJSON.JSON]?) -> [RegionTrigger] {
        var regionTriggers = [RegionTrigger]()
        guard let triggers = triggers else { return regionTriggers }
        
        for trigger in triggers {
            if let trigger = trigger.dictionary,
                let RegionTrigger = self.createRegionTrigger(trigger) {
                
                regionTriggers.append(RegionTrigger)
            }
        }
        
        return regionTriggers
    }
    
    fileprivate func createRegionTrigger(_ trigger: [String: SwiftyJSON.JSON]) -> RegionTrigger? {
        guard let condition = trigger["condition"]?.array,
            let actions = trigger["actions"]?.array else {
                return nil
        }
        
        guard let intent = getActivateIntentAction(actions),
            let locationCondition = getLocationCondition(condition), locationCondition.count > 1  else {
                return nil
        }
        
        if let intentName = intent["name"]?.stringValue {
            let country = locationCondition[1].stringValue
            return RegionTrigger(country: country, intent: intentName)
        }
        
        return nil
    }
    
    fileprivate func getLocationCondition(_ condition: [SwiftyJSON.JSON]) -> [SwiftyJSON.JSON]? {
        guard condition.count > 1 else {return nil}
        
        if let andCondition = condition[1].array,
            let pref = andCondition[0].array, pref.count > 1 {
            return pref[1].array
        }
        return nil
    }
    
    fileprivate func getActivateIntentAction(_ actions: [SwiftyJSON.JSON]) -> [String: SwiftyJSON.JSON]? {
        if let firstAction = actions[0].array, firstAction.count > 1,
            let intentAction = firstAction[1].array {
            return intentAction[0].dictionary
        }
        return nil
    }
}
