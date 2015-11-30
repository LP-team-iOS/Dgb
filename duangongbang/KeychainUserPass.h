//
//  KeychainUserPass.h
//  duangongbangUser
//
//  Created by apple on 15/1/9.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainUserPass : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
