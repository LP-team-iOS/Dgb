//
//  UIImage+Resize.h
//  duangongbang
//
//  Created by ljx on 15/6/5.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Resize)
-(UIImage*)resizedImageToSize:(CGSize)dstSize;
-(UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;
@end
