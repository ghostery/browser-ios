//
//  QuerySuggestionView.swift
//  Client
//
//  Created by Mahmoud Adam on 4/9/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

class QuerySuggestionView: UIView {
    
    //MARK:- Constants
    fileprivate let boldFontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor: UIColor.white]
    fileprivate let normalFontAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16), NSAttributedStringKey.foregroundColor: UIColor.white]
    fileprivate let separatorBgColor = UIColor(rgb: 0xC7CBD3)
    fileprivate let margin: CGFloat = 10
    
    //MARK:- instance variables
    var handelAccessoryViewAction: HandelAccessoryAction?
    
    private var currentQuery: String = ""
    private var currentSuggestions: [String] = []
    
    // MARK:- Public APIs
    
    func shouldShowSuggestions() -> Bool {
        return shouldShowSuggestions(query: currentQuery, suggestions: currentSuggestions)
    }
    
    func shouldShowSuggestions(query: String, suggestions: [String]) -> Bool {
        return QuerySuggestions.isEnabled() && currentQuery == query && suggestions.count > 0
    }
    
    func updateCurrentQuery(_ query: String) {
        currentQuery = query
        if query.isEmpty {
            currentSuggestions.removeAll()
            clearSuggestions()
        }
    }
    
    func getCurrentQuery() -> String {
        return currentQuery
    }
    
    func updateSuggestions(_ suggestions: [String]) {
        currentSuggestions = suggestions
    }
    
    func clearSuggestions() {
        let subViews = self.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }
    
    func displayLastestSuggestions() {
        guard shouldShowSuggestions() else {
            return
        }
        self.displaySuggestions(currentQuery, suggestions: currentSuggestions)
    }
    
    func displaySuggestions(_ query: String, suggestions: [String]) {
        guard shouldShowSuggestions(query: query, suggestions: suggestions) else {
            updateSuggestions(suggestions)
            return
        }
        
        self.clearSuggestions()
        currentSuggestions = suggestions
        
        var index = 0
        var x: CGFloat = margin
        var difference:CGFloat = 0
        var offset:CGFloat = 0
        var displayedSuggestions = [(String, CGFloat)]()
        let maxSuggestionsCount = getMaxSuggestionsCount()
        
        // Calcuate extra space after the last suggesion
        for suggestion in suggestions {
            if suggestion.trim() == query.trim() {
                continue
            }
            let suggestionWidth = getWidth(suggestion)
            // show Max N suggestions which does not exceed screen width
            if x + suggestionWidth > self.frame.width || displayedSuggestions.count == maxSuggestionsCount {
                break;
            }
            // increment step
            x = x + suggestionWidth + 2*margin + 1
            index = index + 1
            displayedSuggestions.append((suggestion, suggestionWidth))
        }
        
        // distribute the extra space evenly on all suggestions
        difference = self.frame.width - x
        offset = round(difference/CGFloat(index))
        
        // draw the suggestions inside the view
        x = margin
        index = 0
        for (suggestion, width) in displayedSuggestions {
            let suggestionWidth = width + offset
            // Adding vertical separator between suggestions
            if index > 0 {
                let verticalSeparator = createVerticalSeparator(x)
                self.addSubview(verticalSeparator)
            }
            // Adding the suggestion button
            let suggestionButton = createSuggestionButton(x, index: index, suggestion: suggestion, suggestionWidth: suggestionWidth)
            self.addSubview(suggestionButton)
            
            // increment step
            x = x + suggestionWidth + 2*margin + 1
            index = index + 1
        }
        //TODO: Telemetry
//        let availableCount = suggestions.count > 3 ? 3 : suggestions.count
//        let customData = ["qs_show_count" : displayedSuggestions.count, "qs_available_count" : availableCount]
//        TelemetryLogger.sharedInstance.logEvent(.QuerySuggestions("show", customData))
    }
    
    //MARK:- Helper methods
    fileprivate func getMaxSuggestionsCount() -> Int {
        if UIDevice.current.isiPad() && !UIDevice.current.isPortrait {
            return 5
        }
        return 3
    }
    
    fileprivate func getWidth(_ suggestion: String) -> CGFloat {
        let sizeOfString = (suggestion as NSString).size(withAttributes: boldFontAttributes)
        return sizeOfString.width + 5
    }
    
    fileprivate func createVerticalSeparator(_ x: CGFloat) -> UIView {
        let verticalSeparator = UIView()
        verticalSeparator.frame = CGRect(x: x-11, y: 0, width: 1, height: self.frame.height)
        verticalSeparator.backgroundColor = separatorBgColor
        return verticalSeparator;
    }
    
    fileprivate func createSuggestionButton(_ x: CGFloat, index: Int, suggestion: String, suggestionWidth: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        let suggestionTitle = getTitle(suggestion)
        button.setAttributedTitle(suggestionTitle, for: UIControlState())
        button.frame = CGRect(x: x, y: 0, width: suggestionWidth, height: self.frame.height)
        button.addTarget(self, action: #selector(selectSuggestion(_:)), for: .touchUpInside)
        button.tag = index
        return button
    }
    
    fileprivate func getTitle(_ suggestion: String) -> NSAttributedString {
        
        let prefix = currentQuery
        var title: NSMutableAttributedString!
        
        if let range = suggestion.range(of: prefix), range.lowerBound == suggestion.startIndex {
            title = NSMutableAttributedString(string:prefix, attributes:normalFontAttributes)
            var suffix = suggestion
            suffix.replaceSubrange(range, with: "")
            title.append(NSAttributedString(string: suffix, attributes:boldFontAttributes))
            
        } else {
            title = NSMutableAttributedString(string:suggestion, attributes:boldFontAttributes)
        }
        return title
    }
    
    @objc fileprivate func selectSuggestion(_ button: UIButton) {
        
        guard let suggestion = button.titleLabel?.text else {
            return
        }
        handelAccessoryViewAction?(.AutoComplete(suggestion + " "))

        //TODO: Telemetry
//        let customData = ["index" : button.tag]
//        TelemetryLogger.sharedInstance.logEvent(.QuerySuggestions("click", customData))
    }
}
