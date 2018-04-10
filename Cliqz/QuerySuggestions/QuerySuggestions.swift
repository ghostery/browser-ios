//
//  QuerySuggestions.swift
//  Client
//
//  Created by Mahmoud Adam on 4/9/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class QuerySuggestions: NSObject {
    //MARK:- Constants
    static let ShowSuggestionsNotification = NSNotification.Name(rawValue: "ShowSuggestionsNotification")
    
    //MARK:- public APIs
    class func querySuggestionEnabledForCurrentRegion() -> Bool {
        return SettingsPrefs.shared.getRegionPref() == "DE"
    }
    
    class func isEnabled() -> Bool {
        return SettingsPrefs.shared.getQuerySuggestionPref() == true && QuerySuggestions.querySuggestionEnabledForCurrentRegion()
    }
}
