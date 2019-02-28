//
//  LegacyTelemetryHelper.swift
//  Client
//
//  Created by Mahmoud Adam on 2/26/19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import UIKit

class LegacyTelemetryHelper: NSObject {
    class func logOnboarding(action: String, page: Int, target: String? = nil) {
        var signal: [String : Any] = ["type": "onboarding", "action": action, "page": page, "version": 1]
        if let target = target { signal["target"] = target }
        
        sendSignal(signal)
    }
    
    class func logPayment(action: String, target: String? = nil) {
        var signal: [String : Any] = ["type": "payment", "action": action, "version": 1]
        if let target = target { signal["target"] = target }
        
        sendSignal(signal)
    }
    
    class func logVPN(action: String, target: String? = nil, state: String? = nil, location: String? = nil, connectionTime: Int? = nil) {
        var signal: [String : Any] = ["type": "vpn", "action": action, "version": 1]
        if let target = target { signal["target"] = target }
        if let state = state { signal["state"] = state }
        if let location = location { signal["location"] = location }
        if let connectionTime = connectionTime { signal["connection_time"] = connectionTime }
        
        sendSignal(signal)
    }
    
    class func logPageLoad() {
        let signal: [String : Any] = ["type": "navigation", "action": "pageLoad", "version": 1]
        sendSignal(signal)
    }
    
    class func logMessage(action: String, topic: String, style: String, view: String, target: String? = nil) {
        var signal: [String : Any] = ["type": "message", "action": action, "topic": topic, "style": style, "version": 1]
        if let target = target { signal["target"] = target }
        
        let currentSubscription = SubscriptionController.shared.getCurrentSubscription()
        signal["state"] = currentSubscription.getTelegetryState()
        if let daysLeft = currentSubscription.trialRemainingDays() { signal["days_left"] = daysLeft }
        
        sendSignal(signal)
    }
    
    private class func sendSignal(_ signal: [String: Any]) {
        DispatchQueue.global(qos: .utility).async {
            Engine.sharedInstance.getBridge().callAction("core:sendTelemetry", args: [signal])
        }
    }
}
