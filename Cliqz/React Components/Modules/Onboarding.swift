//
//  Onboarding.swift
//  Client
//
//  Created by Khaled Tantawy on 17.07.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import React

@objc(Onboarding)
class Onboarding: RCTEventEmitter {
    
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(tryLumenSearch:)
    func tryLumenSearch(accepted: Bool) {
        debugPrint("tryLumenSearch -- \(accepted)")
        if accepted {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: MakeLumenDefaultSearchNotification, object: nil, userInfo: nil)
            }
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: CloseSearchOnboardingNotification, object: nil, userInfo: nil)
            }
        }
    }
}
