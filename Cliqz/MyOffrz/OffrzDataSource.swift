//
//  OffrzDataSource.swift
//  Client
//
//  Created by Sahakyan on 12/5/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation
import RxSwift

class OffrzDataSource {
	
	private var currentOffr: Offr?
	private static let LastSeenOffrID = "LastSeenOffrID"
	private static let OffrzOnboardingKey = "OffrzOnboardingNeeded"
    let observable = BehaviorSubject(value: false)

	var myOffrz = [Offr]()
    private var lastFetchDate: Date?
    private let expirationDuration = 3600.0 // refresh every hour
    private var region = SettingsPrefs.shared.getRegionPref()
    
	static let shared = OffrzDataSource()

    init() {
        self.loadOffrz()
    }
    
	func getCurrentOffr() -> Offr? {
		if let o = self.currentOffr,
			self.isExpiredOffr(o) {
			self.currentOffr = nil
			self.loadOffrz()
		}
		return self.currentOffr
	}

	func shouldShowOffrz() -> Bool {
		// TODO: should be checked prefs after merging with settings
		return true
//		return SettingsPrefs.shared.getUserRegionPref() == "DE"
	}

	func hasUnseenOffrz() -> Bool {
        #if PAID
        return false
        #else
		return !(self.currentOffr?.isSeen ?? true)
        #endif
	}

	func markCurrentOffrSeen() {
		self.currentOffr?.isSeen = true
        LocalDataStore.set(value: self.currentOffr?.uid, forKey: OffrzDataSource.LastSeenOffrID)
	}

    func hasOffrz() -> Bool {
        return self.getCurrentOffr() != nil
    }

    func shouldShowOnBoarding() -> Bool {
        guard let _ = LocalDataStore.value(forKey: OffrzDataSource.OffrzOnboardingKey)
			else {
			return true
		}
        return false
    }

    func hideOnBoarding() {
        LocalDataStore.set(value: "closed", forKey: OffrzDataSource.OffrzOnboardingKey)
    }
    
	func loadOffrz() {
        guard shouldRefreshOffers() else { return }
        
        self.region = SettingsPrefs.shared.getRegionPref()
        OffrzDataService.shared.getMyOffrz(region: region) { (offrz, error) in
            guard error == nil else { return }
            self.myOffrz = offrz
			if offrz.count > 0 {
				if let o = self.getLastSeenOffr() {
					self.currentOffr = o
					self.currentOffr?.isSeen = true
				} else {
                    LocalDataStore.removeObject(forKey: OffrzDataSource.LastSeenOffrID)
					self.currentOffr = self.getNotExpiredOffr()
				}
            } else {
                self.currentOffr = nil
            }
            self.lastFetchDate = Date()
            self.observable.on(.next(true))
		}
	}
    
    private func shouldRefreshOffers() -> Bool {
        if self.region != SettingsPrefs.shared.getRegionPref() {
            return true
        }
        return self.lastFetchDate == nil || Date().timeIntervalSince(self.lastFetchDate!) > self.expirationDuration
    }
    
	private func getNotExpiredOffr() -> Offr? {
		for o in self.myOffrz {
			if !self.isExpiredOffr(o) {
				return o
			}
		}
		return nil
	}
    
	private func getLastSeenOffr() -> Offr? {
		let offrID = self.getLastSeenOffrID()
		for o in self.myOffrz {
			if o.uid == offrID {
				if !self.isExpiredOffr(o) {
					return o
				}
			}
		}
		return nil
    }

	private func getLastSeenOffrID() -> String? {
        return LocalDataStore.value(forKey: OffrzDataSource.LastSeenOffrID) as? String
	}

	private func isExpiredOffr(_ offr: Offr) -> Bool {
		let now =  Date()
		if let start = offr.startDate,
			let end = offr.endDate {
			return start > now || end < now
		}
		return false
	}
}
