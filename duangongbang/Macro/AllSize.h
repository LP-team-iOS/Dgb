//
//  AllSize.h
//  loginDemo
//
//  Created by apple on 15/1/4.
//  Copyright (c) 2015年 apple. All rights reserved.
//


#ifndef loginDemo_AllSize_h
#define loginDemo_AllSize_h

#endif

//      获取主屏的尺寸
#define mainScreenSize ([UIScreen mainScreen].bounds.size)

//      当前屏幕的高度
#define mainScreenHeight ([UIScreen mainScreen].applicationFrame.size.height)

//      当前屏幕的宽度
#define mainScreenWidth  ([UIScreen mainScreen].applicationFrame.size.width)

//      判断当前设备是不是iphone4
#define isIphone4 (([[UIScreen mainScreen] bounds].size.height) == 480)

//      得到视图的尺寸:宽度、高度
#define VIEW_W(view)  (view.frame.size.width)
#define VIEW_H(view)  (view.frame.size.height)

//      得到frame的X,Y坐标点
#define FRAME_TX(frame)  (frame.origin.x)
#define FRAME_TY(frame)  (frame.origin.y)

//      得到frame的宽度、高度
#define FRAME_W(frame)  (frame.size.width)
#define FRAME_H(frame)  (frame.size.height)

#define Width [UIScreen mainScreen].bounds.size.width
#define Height [UIScreen mainScreen].bounds.size.height

//cell高度
#define kCellHeight ((([UIScreen mainScreen].bounds.size.width)/320 == 1) ? 90:107)
