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
    
    private class func sendSignal(_ signal: [String: Any]) {
        Engine.sharedInstance.getBridge().callAction("core:sendTelemetry", args: [signal])
    }
}
