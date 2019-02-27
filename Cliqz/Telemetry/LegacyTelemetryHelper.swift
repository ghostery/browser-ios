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
    
    private class func sendSignal(_ signal: [String: Any]) {
        DispatchQueue.global(qos: .utility).async {
            Engine.sharedInstance.getBridge().callAction("core:sendTelemetry", args: [signal])
        }
    }
}
