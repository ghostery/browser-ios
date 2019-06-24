//
//  Telemetry.swift
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import React

@objc(Telemetry)
class TelemetryJS: RCTEventEmitter {
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    open override static func moduleName() -> String! {
        return "Telemetry"
    }
    
    @objc(sendTelemetry:)
    func sendTelemetry(data: NSString?) {
        debugPrint("send telemetry")
        if let data = data {
            if let json = (data as String).parseJSONString as? [String: Any] {
                //TelemetryLogger.sharedInstance.logEvent(.JavaScriptSignal(json))
            }
        }
    }
}

extension String {
    
    var parseJSONString: Any? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            return try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}

