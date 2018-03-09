//
//  SearchDelegate.swift
//  Client
//
//  Created by Sahakyan on 3/8/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import Foundation
import Storage

//Cliqz: Replace Search Controller
extension BrowserViewController: SearchViewDelegate {
	func didSelectURL(_ url: URL, searchQuery: String?) {
		finishEditingAndSubmit(url, visitType: VisitType.typed)
	}
	
	func autoCompeleteQuery(_ autoCompleteText: String) {
		urlBar.setAutocompleteSuggestion(autoCompleteText)
	}
	
	func dismissKeyboard() {
		urlBar.hideKeyboard()
	}
}
