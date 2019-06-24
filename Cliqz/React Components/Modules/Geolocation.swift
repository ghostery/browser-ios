//
//  Geolocation.swift
//  Client
//
//  Created by Tim Palade on 4/11/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import React

@objc(GeoLocation)
class GeoLocation: RCTEventEmitter {
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc(getCurrentPosition:reject:)
    func getCurrentPosition(resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        //use only the resolve block
        if let l = LocationManager.sharedInstance.getUserLocation() {
            resolve(["latitude": l.coordinate.latitude, "longitude": l.coordinate.longitude])
        }
    }
}
