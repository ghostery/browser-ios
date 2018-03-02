//
//  ShareCardModule.m
//  Client
//
//  Created by Tim Palade on 1/3/18.
//  Copyright © 2018 Mozilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(ShareCardModule, NSObject)
RCT_EXTERN_METHOD(share:(NSDictionary*)data success:(RCTResponseSenderBlock)success error:(RCTResponseErrorBlock)error)
@end
