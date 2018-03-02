//
//  BrowserActionsBridge.m
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(BrowserActions, NSObject)
RCT_EXTERN_METHOD(searchHistory:(nonnull NSString *)query callback:(RCTResponseSenderBlock))
@end
