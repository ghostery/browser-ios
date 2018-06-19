//
//  SubscriptionModule.swift
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//
//import React
//
//@objc(SubscriptionModule)
//open class SubscriptionModule: RCTEventEmitter {
//    
//    @objc(isSubscribedBatch:resolve:reject:)
//    func isSubscribedBatch(batch: NSArray, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
//        debugPrint("isSubscribedBatch")
//
//        let result = batch.map { (dict) -> Bool in
//            if let dict = dict as? NSDictionary {
//                if let type = dict["type"] as? String, let subType = dict["subtype"] as? String, let id = dict["id"] as? String {
//                    return SubscriptionsHandler.sharedInstance.isSubscribed(withType: type, subType: subType, id: id)
//                }
//            }
//            return false
//        }
//        
//        resolve(result)
//    }
//    
//    @objc(isSubscribed:subType:identifier:resolve:reject:)
//    func isSubscribed(type: NSString, subType: NSString, identifier: NSString?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
//        debugPrint("isSubscribed")
//        
//        var isSubscribed = false
//        
//        if let id = identifier {
//            isSubscribed = SubscriptionsHandler.sharedInstance.isSubscribed(withType: type as String, subType: subType as String, id: id as String)
//        }
//        
//        resolve(isSubscribed)
//    }
//    
//    @objc(subscribeToNotifications:subType:identifier:resolve:reject:)
//    func subscribeToNotifications(type: NSString, subType: NSString, identifier: NSString?, resolve: @escaping RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
//        debugPrint("subscribeToNotifications")
//        if let id = identifier {
//            let notificationType = RemoteNotificationType.subscriptoinNotification(type as String, subType as String, id as String)
//            SubscriptionsHandler.sharedInstance.subscribeForRemoteNotification(ofType: notificationType, completionHandler: { _ in
//                resolve(true)
//            })
//        }
//        else {
//            resolve(false)
//        }
//    }
//    
//    @objc(unsubscribeToNotifications:subType:identifier:resolve:reject:)
//    func unsubscribeToNotifications(type: NSString, subType: NSString, identifier: NSString?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock) {
//        debugPrint("unsubscribeToNotifications")
//        if let id = identifier {
//            let notificationType = RemoteNotificationType.subscriptoinNotification(type as String, subType as String, id as String)
//            SubscriptionsHandler.sharedInstance.unsubscribeForRemoteNotification(ofType: notificationType)
//            resolve(true)
//        }
//        else {
//            resolve(false)
//        }
//    }
//}
