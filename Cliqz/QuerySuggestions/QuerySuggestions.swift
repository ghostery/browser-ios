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
    private static let supportedRegions = ["DE", "US", "GB", "FR", "IT", "ES", "AU", "AUS", "RU", "CA"]
    
    //MARK:- public APIs
    //TODO: optimize this method by storing current region and update it when use change it
    class func querySuggestionEnabledForCurrentRegion() -> Bool {
        let currentRegion = SettingsPrefs.shared.getRegionPref()
        return QuerySuggestions.supportedRegions.contains(currentRegion)
    }
    
    class func isEnabled() -> Bool {
        return SettingsPrefs.shared.getQuerySuggestionPref() == true && QuerySuggestions.querySuggestionEnabledForCurrentRegion()
    }
}
