//
//  AllColor.h
//  loginDemo
//
//  Created by apple on 15/1/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//




#ifndef loginDemo_AllColor_h
#define loginDemo_AllColor_h

#endif

////      rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]

//      RGBA颜色设置
#define RGB(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f                      alpha:a]

//      清除背景色
#define CLEARCOLOR [UIColor                                                                           clearColor]

//      loginBtnGreen
#define kGreenColor [UIColor colorWithRed:41.0f / 255.f green:203.0f / 255.f blue:136.0f / 255.f       alpha:1.0f]

//      defaultBtnGray
#define kGrayColor [UIColor colorWithRed:215.0f / 255.f green:215.0f / 255.f blue:215.0f / 255.f       alpha:1.0f]
//
//      tabBarBtn
#define tabBarBtnBGColor [UIColor colorWithRed:99.0f / 255.f green:192.0f / 255.f blue:197.0f / 255.f alpha:1.0f]
//
//      defaultBtnTintGray
#define deepGrayColor [UIColor colorWithRed:102.0f / 255.f green:102.0f / 255.f blue:102.0f / 255.f   alpha:1.0f]

//      mainUIBlue
#define mainBlueColor [UIColor colorWithRed:56.0f / 255.f green:134.0f / 255.f blue:190.0f / 255.f    alpha:1.0f]

//      noSelected
#define kSelectGrayColor [UIColor colorWithRed:88.0f / 255.f green:88.0f / 255.f blue:88.0f / 255.f   alpha:1.0f]

//      refreshBGC
#define kRefreshBGC [UIColor colorWithRed:215.0f / 255.f green:215.0f / 255.f blue:215.0f / 255.f     alpha:1.0]

//
#define kGrayBGC [UIColor colorWithRed:237.0f / 255.f green:237.0f / 255.f blue:237.0f / 255.f        alpha:1.0]

#define kResumePinkColor [UIColor colorWithRed:247.0f / 255.f green:122.0f / 255.f blue:130.0f / 255.f alpha:1.0]

#define kmainBlackColor [UIColor colorWithRed:48.0f / 255.f green:50.0f / 255.f blue:63.0f / 255.f alpha:1.0]

#define xTableViewGrayColor 0xededed

#define xHeadViewGrayColor 0xf6f6f6

#define xRegistBackgroundColor 0x0e0e0e

#define xBoderColor1 0xd6d6d6

#define xFontColor1 0x666666

#define xMainBlueColor 0x02a8f3

#define xMainBlackColor 0x30323F

#define xButtonRed 0xfc7a82

#define xBaseBlack 0x212121

#define xAlertColor 0xB5B5B5

#define kToolGrayColor 0x4f5156

#define kTooLBackColor 0x2E3036

#define kBlue0x3886be 0x3886be

#define kGray0x717171 0x717171