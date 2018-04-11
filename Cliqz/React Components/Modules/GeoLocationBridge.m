//
//  GeolocationBridge.m
//  Client
//
//  Created by Tim Palade on 4/11/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(GeoLocation, NSObject)
RCT_EXTERN_METHOD(getCurrentPosition:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
@end
