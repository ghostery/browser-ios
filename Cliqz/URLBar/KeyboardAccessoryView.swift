//
//  KeyboardAccessoryView.swift
//  Client
//
//  Created by Mahmoud Adam on 4/9/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import UIKit

enum AccessoryViewAction {
    case AutoComplete(String)
}

typealias HandelAccessoryAction = (AccessoryViewAction) -> Void

class KeyboardAccessoryView: UIView {
    
    static let sharedInstance = KeyboardAccessoryView()
    
    // MARK:- Static constants
    private let kViewHeight: CGFloat = 44
    private let KBackgroundColor = UIColor(rgb: 0xADB5BD)
    private let querySuggestionView = QuerySuggestionView()
    
    // MARK:- Initialization
    init() {
        let screenBounds = UIScreen.main.bounds
        let width = min(screenBounds.width, screenBounds.height)
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: kViewHeight);
        
        super.init(frame: frame)
        self.autoresizingMask = .flexibleWidth
        self.backgroundColor = KBackgroundColor//.withAlphaComponent(0.85)
        
        querySuggestionView.frame = frame
        querySuggestionView.autoresizingMask = .flexibleWidth
        self.addSubview(querySuggestionView)
        
        // initial statue the bar is hidden
        self.isHidden = true
        
        // Notifications Observers
        NotificationCenter.default.addObserver(self, selector: #selector(showSuggestions) , name: QuerySuggestions.ShowSuggestionsNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Public APIs
    func updateCurrentQuery(_ query: String) {
        querySuggestionView.updateCurrentQuery(query)
        self.refreshView()
    }
    
    func setHandelAccessoryViewAction(_ handelAccessoryViewAction: @escaping HandelAccessoryAction) {
        querySuggestionView.handelAccessoryViewAction = handelAccessoryViewAction
    }
    
    // MARK:- Private Helpers
    @objc fileprivate func showSuggestions(notification: NSNotification) {
        querySuggestionView.clearSuggestions()
        
        if
            let suggestionsData = notification.object as? [String: AnyObject],
            let query = suggestionsData["query"] as? String,
            let suggestions = suggestionsData["suggestions"] as? [String] {
            
            querySuggestionView.displaySuggestions(query, suggestions: suggestions)
        }
    }
    
    @objc fileprivate func viewRotated() {
        self.refreshView()
        
        // Used DispatchQueue.async to ensure updating the frame width
        DispatchQueue.main.async { [weak self] in
            self?.querySuggestionView.displayLastestSuggestions()
        }
    }
    
    private func refreshView() {
        if (UIDevice.current.isPortrait || UIDevice.current.isiPad()) && QuerySuggestions.isEnabled() && !querySuggestionView.getCurrentQuery().isEmpty {
            self.isHidden = false
        } else {
             self.isHidden = true
        }
    }
}
