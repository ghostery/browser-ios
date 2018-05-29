//
//  OffrzDataSource.swift
//  Client
//
//  Created by Sahakyan on 12/5/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import Foundation

class OffrzDataSource {
	
	private var currentOffr: Offr?
	private static let LastSeenOffrID = "LastSeenOffrID"
	private static let OffrzOnboardingKey = "OffrzOnboardingNeeded"

	var myOffrz = [Offr]()

	init() {
		self.updateMyOffrzList()
	}

	static let shared = OffrzDataSource()

	func getCurrentOffr() -> Offr? {
		if let o = self.currentOffr,
			self.isExpiredOffr(o) {
			self.currentOffr = nil
			// TODO: Impl notify on currentOffr change....
			self.updateMyOffrzList()
		}
		return self.currentOffr
	}

	func shouldShowOffrz() -> Bool {
		// TODO: should be checked prefs after merging with settings
		return true
//		return SettingsPrefs.shared.getUserRegionPref() == "DE"
	}

	func hasUnseenOffrz() -> Bool {
		return !(self.currentOffr?.isSeen ?? true)
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

	private func updateMyOffrzList() {
		OffrzDataService.shared.getMyOffrz { (offrz, error) in
			if error == nil && offrz.count > 0 {
				self.myOffrz = offrz
				if let o = self.getLastSeenOffr() {
					self.currentOffr = o
					self.currentOffr?.isSeen = true
				} else {
                    LocalDataStore.removeObject(forKey: OffrzDataSource.LastSeenOffrID)
					self.currentOffr = self.getNotExpiredOffr()
				}
			}
		}
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
