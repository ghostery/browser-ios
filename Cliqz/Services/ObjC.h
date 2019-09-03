//
//  ObjC.h
//  Client
//
//  Created by Krzysztof Modras on 03.09.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjC : NSObject

+ (BOOL)catchException:(void(^)(void))tryBlock error:(__autoreleasing NSError **)error;

@end
