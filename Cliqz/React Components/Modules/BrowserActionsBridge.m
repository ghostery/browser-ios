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
RCT_EXTERN_METHOD(openLink:(nonnull NSString *)url query:(nonnull NSString *)query isSearchEngine:(BOOL)isSearchEngine)
RCT_EXTERN_METHOD(copyValue:(nonnull NSString *)result)
RCT_EXTERN_METHOD(callNumber:(nonnull NSString *)number)
RCT_EXTERN_METHOD(openMap:(nonnull NSString *)url)
RCT_EXTERN_METHOD(hideKeyboard)
@end
