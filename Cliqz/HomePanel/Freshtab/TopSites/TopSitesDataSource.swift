//
//  TopSitesDataSource.swift
//  Client
//
//  Created by Sahakyan on 3/1/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import Deferred
import Storage
import Shared
import RxSwift

private let DefaultSuggestedSitesKey = "topSites.deletedSuggestedSites"

class TopSitesDataSource {
    
    static let instance = TopSitesDataSource()
	let observable = BehaviorSubject(value: false)

	private var profile: Profile!
	private var topSites = [Site]()
    private var hiddenTopSitesIndexes = [Int]()

	init() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate, let profile = delegate.profile {
            self.profile = profile
        }
		self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceHighlights: false, forceTopSites: true)
		self.loadTopSites()
	}

	func refresh() {
		self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceHighlights: true, forceTopSites: true)
		self.loadTopSites()
	}

	func topSitesCount() -> Int {
		return self.topSites.count
	}

	func getTopSite(at: Int) -> Site? {
		if at < topSites.count && !hiddenTopSitesIndexes.contains(at) {
			return topSites[at]
		}
		return nil
	}

	private func loadTopSites() {
        hiddenTopSitesIndexes = [Int]()
		let _ =		self.profile.history.getTopSitesWithLimit(16).both(self.profile.history.getPinnedTopSites()).bindQueue(.main) { (topsites, pinnedSites)  -> Success in
			guard let mySites = topsites.successValue?.asArray(), let pinned = pinnedSites.successValue?.asArray() else {
				return succeed()
			}
			// How sites are merged together. We compare against the urls second level domain. example m.youtube.com is compared against `youtube`
			let unionOnURL = { (site: Site) -> String in
				return URL(string: site.url)?.hostSLD ?? ""
			}
			
			// Fetch the default sites
			let defaultSites = [Site]()
			// create PinnedSite objects. used by the view layer to tell topsites apart
			let pinnedSites: [Site] = pinned.map({ PinnedSite(site: $0) })
			
			// Merge default topsites with a user's topsites.
			let mergedSites = mySites.union(defaultSites, f: unionOnURL)
			// Merge pinnedSites with sites from the previous step
			let allSites = pinnedSites.union(mergedSites, f: unionOnURL)
			
			// Favour topsites from defaultSites as they have better favicons. But keep PinnedSites
			let newSites = allSites.map { site -> Site in
				if let _ = site as? PinnedSite {
					return site
				}
				let domain = URL(string: site.url)?.hostSLD
				return defaultSites.find { $0.title.lowercased() == domain } ?? site
			}

			if newSites.count > Int(ActivityStreamTopSiteCacheSize) {
				self.topSites = Array(newSites[0..<Int(ActivityStreamTopSiteCacheSize)])
			} else {
				self.topSites = newSites
			}
			self.observable.on(.next(true))
			
			return succeed()
		}
	}

	func hideTopSite(at index: Int) {
		guard index < self.topSites.count else {
			return
		}
        hiddenTopSitesIndexes.append(index)
		let site = self.topSites[index]
		if let _ =  site as? PinnedSite {
			// If pinned site, then should be removed from pinned and then hided from topSites
			profile.history.removeFromPinnedTopSites(site).uponQueue(.main) { result in
				guard result.isSuccess else { return }
				self.hideURLFromTopSite(site)
			}
		} else {
			self.hideURLFromTopSite(site)
		}
	}

	private func hideURLFromTopSite(_ site: Site) {
		guard let host = site.tileURL.normalizedHost else {
			return
		}
		profile.history.removeHostFromTopSites(host).uponQueue(.main) { _ in
		}
	}

}
