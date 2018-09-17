//
//  SearchEnginesModuleBridge.m
//  Client
//
//  Created by Mahmoud Adam on 9/17/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(SearchEnginesModule, NSObject)
RCT_EXTERN_METHOD(getSearchEngines:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
