//
//  BrowserViewController.swift
//  Client
//
//  Created by Mahmoud Adam on 6/12/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit
import Shared

extension BrowserViewController {
    
    func showKeyboardIfNeeded() {
        guard shouldShowKeyboard() else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.urlBar?.enterOverlayMode("", pasted: false, search: true)
        }
    }
    
    func shouldShowKeyboard() -> Bool {
        if profile.prefs.intForKey(PrefsKeys.IntroSeen) == nil {
            return false
        }
		if !(self.homePanelController?.shouldShowKeyboard ?? false) {
			return false
		}
        let selectedHomePanel = homePanelController?.selectedPanel ?? .topSites
        let selectedTab = self.tabManager.selectedTab
        
        guard selectedHomePanel == .topSites else { return false }
        if let url = selectedTab?.url {
            return url.isAboutURL
        } else if let tab = selectedTab {
            return tab.restoringFreshtab
        }
        
        return false
    }

	func shouldHideSearchView(newQuery: String, oldQuery: String?, urlBar: URLBarView) -> Bool {
		return newQuery.isEmpty && (!(urlBar.locationTextField?.isSelectionActive ?? false) || (oldQuery?.isEmpty ?? true))
	}
}
