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
    
    class func logPromoPayment(action: String, target: String? = nil, view: String? = nil, topic: String? = nil) {
        var signal: [String : Any] = ["type": "payment", "action": action, "version": 2]
        if let target = target { signal["target"] = target }
        if let view = view { signal["view"] = view }
        if let topic = topic { signal["topic"] = topic }
        
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

    class func logLumenSearchWarning(action: String, target: String? = nil) {
        var signal: [String : Any] = ["type": "search", "view": "leave", "version": 1]
        if let target = target { signal["target"] = target }
        signal["action"] = action

        sendSignal(signal)
    }
    
    class func logDashboard(action: String, target: String? = nil, state: String? = nil) {
        var signal: [String : Any] = ["type": "dashboard", "action": action, "version": 1]
        if let target = target { signal["target"] = target }
        if let state = state { signal["state"] = state }
        
        sendSignal(signal)
    }
    
    class func logTelemetrySetting(state: Bool) {
        var signal: [String : Any] = ["type": "settings", "action": "toggle", "target": "send_telemetry", "version": 1]
        signal["state"] = state ? "on" : "off"

        sendSignal(signal)
    }
    
    class func logStateChanged(state: String) {
        let signal: [String : Any] = ["type": "app", "action": "stateChange", "state": state, "version": 1]
        sendSignal(signal)
    }
    
    class func logPush(action: String, topic: String) {
       let signal: [String : Any] = ["type": "push", "action": action, "topic": topic, "version": 1]
        sendSignal(signal)
    }
    
    private class func sendSignal(_ signal: [String: Any]) {
        #if PAID
        DispatchQueue.global(qos: .utility).async {
            Engine.sharedInstance.getBridge().callAction("core:sendTelemetry", args: [signal, true])
        }
        #endif
    }
}
