//
//  NewsDataSource.swift
//  Client
//
//  Created by Sahakyan on 2/15/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import RxSwift

class NewsDataSource {
    
    static let instance = NewsDataSource()
	private let expirationDuration: TimeInterval = 1800

	private var lastNews = [News]()
	private var lastFetchDate: Date?

	let observable = BehaviorSubject(value: false)

	// TODO: Check how often we need to reload news?? Or if it makes sence to preiodically load news on background
	init() {
		self.loadNews()
	}

	func shouldShowNews() -> Bool {
		return true
	}

	func newsCount() -> Int {
		return lastNews.count
	}

	func getNews(at: Int) -> News? {
		if at < lastNews.count {
			return lastNews[at]
		}
		return nil
	}

	func isEmpty() -> Bool {
		return lastNews.count == 0
	}

	func getNewsViewModel(at: Int) -> NewsCellViewModel? {
		if let news = self.getNews(at: at) {
			let newsViewModel = NewsCellViewModel(news)
			if let url = newsViewModel.logoURL {
				LogoLoader.loadLogo(url, completionBlock: { (image, logoInfo, error) in
					if let img = image {
						newsViewModel.logo.value = img
					} else if let info = logoInfo {
						newsViewModel.logoInfo.value = info
					}
				})
			}
			return newsViewModel
		}
		return nil
	}

	func loadNews() {
		guard self.isEmpty() || self.isExpired() else {
			return
		}
		NewsDataService.loadLastNews { (news, error) in
			if error != nil {
				self.lastNews = [News]()
			} else {
				self.lastNews = news
			}
			self.lastFetchDate = Date()
			self.observable.on(.next(true))
		}
	}

	private func isExpired() -> Bool {
		return self.lastFetchDate == nil || Date().timeIntervalSince(self.lastFetchDate!) > self.expirationDuration
	}
}
