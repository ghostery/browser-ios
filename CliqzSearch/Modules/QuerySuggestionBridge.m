//
//  QuerySuggestionBridge.m
//  Client
//
//  Created by Tim Palade on 12/29/17.
//  Copyright © 2017 Mozilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(QuerySuggestion, NSObject)
RCT_EXTERN_METHOD(showQuerySuggestions:(nullable NSString *)query suggestions:(nullable NSArray*)suggestions)
@end
