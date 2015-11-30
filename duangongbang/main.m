//
//  main.m
//  duangongbang
//
//  Created by ljx on 15/4/23.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <BmobSDK/Bmob.h>

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSString *appKey = kBmobSDKKey;
        [Bmob registerWithAppKey:appKey];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
