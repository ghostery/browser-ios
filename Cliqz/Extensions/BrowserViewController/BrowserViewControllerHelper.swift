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
        
        DispatchQueue.main.async { [weak self] in
            let locationText = self?.urlBar?.locationTextField?.text
            if  locationText == nil || locationText!.isEmpty {
                self?.urlBar?.enterOverlayMode("", pasted: false, search: true)
            }
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
        
        if selectedHomePanel != .topSites {
            return false
        } else if let tab = selectedTab {
            return tab.restoringFreshtab
        } else if let url = selectedTab?.url {
            return url.isAboutURL
        }
        
        return false
    }

	func shouldHideSearchView(newQuery: String, oldQuery: String?, urlBar: URLBarView) -> Bool {
		return newQuery.isEmpty && (!(urlBar.locationTextField?.isSelectionActive ?? false) || (oldQuery?.isEmpty ?? true))
	}
}
