//
//  AutoCompletion.swift
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

import React

let AutoCompleteNotification = Notification.Name(rawValue: "reactAutoCompleteNotification")

@objc(AutoCompletion)
class AutoCompletion: RCTEventEmitter {
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(autoComplete:)
    func autoComplete(data: NSString) {
        debugPrint("autocomplete -- \(data)")
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: AutoCompleteNotification, object: data)
        }
    }
}
