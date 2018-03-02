//
//  QuerySuggestion.swift
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import React

@objc(QuerySuggestion)
open class QuerySuggestion: RCTEventEmitter {
    @objc(showQuerySuggestions:suggestions:)
    func showQuerySuggestions(query: NSString?, suggestions: NSArray?) {
        debugPrint("showQuerySuggestions")
        if let query = query, let suggestions = suggestions {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: QuerySuggestions.ShowSuggestionsNotification, object: ["query": query, "suggestions": suggestions])
            }
        }
    }
}
