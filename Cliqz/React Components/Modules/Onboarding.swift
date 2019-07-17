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
            // TODO: PK this is try now case. Change Lumen to default search engine. UI will be handled by extenstion
        } else {
            // TODO: PK close cliqz search and open queary with default search engine
        }
    }
}
