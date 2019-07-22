//
//  JSBridgeBridge.m
//  Client
//
//  Created by Sam Macbeth on 21/02/2017.
//  Copyright © 2017 Mozilla. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(JSBridge, NSObject)

RCT_EXTERN_METHOD(replyToAction:(nonnull NSInteger *)actionId result:(NSDictionary *)result)
RCT_EXTERN_METHOD(registerAction:)
RCT_EXTERN_METHOD(pushEvent:(nonnull NSString *)eventId data:(NSArray *)data)
RCT_EXTERN_METHOD(getConfig:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
