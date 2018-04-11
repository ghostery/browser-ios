//
//  PermissionManagerModule.swift
//  Client
//
//  Created by Tim Palade on 4/11/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

import React

@objc(PermissionManagerModule)
class PermissionManagerModule: RCTEventEmitter {
    
    let permissions = ["ACCESS_FINE_LOCATION": "LocationPermission", "WRITE_EXTERNAL_STORAGE": "Undefined for iOS"]
    let results = ["GRANTED": "Success", "REJECTED": "Failure"]
    
    @objc(check:resolve:reject:)
    func check(permission: NSString, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        //use only the resolve block
        
        if String(permission) == permissions["ACCESS_FINE_LOCATION"]! {
            LocationManager.sharedInstance.isLocationAcessEnabled() ? resolve(results["GRANTED"]) : resolve(results["REJECTED"])
        }
    }
    
    @objc(request:resolve:reject:)
    func request(permission:NSString, resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
        //use only the resolve block
        if String(permission) == permissions["ACCESS_FINE_LOCATION"]! {
            LocationManager.sharedInstance.shareLocation(callback: { (result) in
                if result == true {
                    resolve(self.results["GRANTED"])
                }
                else {
                    resolve(self.results["REJECTED"])
                }
            })
        }
    }
    
    override func constantsToExport() -> [AnyHashable : Any]! {
        return ["PERMISSIONS": permissions, "RESULTS": results]
    }
}
