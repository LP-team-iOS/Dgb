//
//  GetVersion.h
//  loginDemo
//
//  Created by apple on 15/1/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#ifndef loginDemo_GetVersion_h
#define loginDemo_GetVersion_h

#endif

//      获取系统版本
#define iOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

//      判断设备系统是不是ios8
#define iOS_8 [[[UIDevice currentDevice].systemVersion doubleValue] >= 8.0]

