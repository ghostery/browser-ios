//
//  BrowserViewController+CliqzMigration.swift
//  Client
//
//  Created by Sahakyan on 6/27/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Shared

extension BrowserViewController {
	private static let updateSeenKey = "CliqzUpdateInfoPageSeen"

	func showCliqzUpdateInfoPageFirstTime() {
		guard isExistingUser(), !isUpdateInfoPageSeen() else {
			return
		}
		let urlStr = "http://cliqz.com/en/magazine/cliqz-ios-update"
		if let url = URL(string: urlStr) {
			self.openURLInNewTab(url, isPrivileged: false)
			self.markUpdateInfoPageSeen()
		}
	}

	private func isExistingUser() -> Bool {
		guard let introSeen = profile.prefs.intForKey(PrefsKeys.IntroSeen), introSeen == 1 else {
			return false
		}
		return true
	}

	private func isUpdateInfoPageSeen() -> Bool {
		if let updateSeen = LocalDataStore.integer(forKey: BrowserViewController.updateSeenKey), updateSeen == 1 {
			return true
		}
		return false
	}

	private func markUpdateInfoPageSeen() {
		LocalDataStore.set(integer: 1, forKey: BrowserViewController.updateSeenKey)
	}

}
