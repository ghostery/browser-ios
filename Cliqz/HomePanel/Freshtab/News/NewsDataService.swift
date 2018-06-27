//
//  NewsDataService.swift
//  Client
//
//  Created by Sahakyan on 2/9/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import Alamofire

struct News {
	let url: String?
	let domain: String?
	let title: String?
	let shortTitle: String?
	let isBreaking: Bool?
	let breakingLabel: String?
	let localLabel: String?
}

class NewsDataService {

	private static let APIURL = "https://api.cliqz.com/api/v2/rich-header?path=/v2/map&q=&lang=N/A&locale=\(Locale.current.identifier)&adult=0&loc_pref=ask&platform=1&sub_platform=11&country=DE"

	static func loadLastNews(completionHandler: @escaping ([News], Error?) -> Void) {
		NewsDataService.loadData(successHandler: { news in
				completionHandler(news, nil)
			}, failureHandler: { (e) in
				completionHandler([], e)
			})
	}

	private static func loadData(successHandler: @escaping ([News]) -> Void, failureHandler: @escaping (Error?) -> Void) {

		// TODO: Region is needed to implement
		let fullURL = NewsDataService.APIURL //+ "&country=\(userRegion!)"
		
		// TODO: current location should be included for Local news
//		if let coord = LocationManager.sharedInstance.getUserLocation() {
//			fullURL += "&loc=\(coord.coordinate.latitude),\(coord.coordinate.longitude)"
//		}

		let data = ["q": "",
					"results": [[ "url": "rotated-top-news.cliqz.com",  "snippet":[String:String]()]]] as [String : Any]

		Alamofire.request(fullURL, method: .put, parameters: data, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
			if response.result.isSuccess {
				if let data = response.result.value as? [String: Any],
					let result = data["results"] as? [[String: Any]] {
					if let snippet = result.first?["snippet"] as? [String: Any],
						let extra = snippet["extra"] as? [String: Any],
						let articles = extra["articles"] as? [[String: Any]] {
						successHandler(NewsDataService.parseNews(articles))
					}
				}
			} else {
				failureHandler(response.error) // TODO proper Error
			}
		}
	}

	private static func parseNews(_ newsArticles: [[String: Any]]) -> [News] {
		var news = [News]()
		for article in newsArticles {
			let isBreaking = article["breaking"] as? NSNumber
			let breakingLabel = article["breaking_label"] as? String
			let localLabel = article["local_label"] as? String
			let title = article["title"] as? String
			let shortTitle = article["short_title"] as? String
			let domain = article["domain"] as? String
			let url = article["url"] as? String
			news.append(News(url: url, domain: domain, title: title, shortTitle: shortTitle, isBreaking: isBreaking?.boolValue, breakingLabel: breakingLabel, localLabel: localLabel))
		}
		return news
	}
}
