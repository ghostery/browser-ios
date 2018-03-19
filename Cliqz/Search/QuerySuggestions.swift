//
//  QuerySuggestions.swift
//  Client
//
//  Created by Mahmoud Adam on 2/27/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import UIKit

class QuerySuggestions: NSObject {
    
    //MARK:- Constants
    static let ShowSuggestionsNotification = NSNotification.Name(rawValue: "ShowSuggestionsNotification")
    
    //MARK:- public APIs
    class func querySuggestionEnabledForCurrentRegion() -> Bool {
        let userRegion = SettingsPrefs.shared.getRegionPref()
        return userRegion == "DE"
    }
    
    class func isEnabled() -> Bool {
        return QuerySuggestions.querySuggestionEnabledForCurrentRegion() && SettingsPrefs.shared.getQuerySuggestionPref()
    }
    
}
