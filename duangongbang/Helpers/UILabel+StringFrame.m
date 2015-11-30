//
//  UILabel+StringFrame.m
//  duangongbang
//
//  Created by ljx on 15/5/26.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "UILabel+StringFrame.h"

@implementation UILabel (StringFrame)
- (CGSize)boundingRectWithSize:(CGSize)size
{
    NSDictionary *attribute = @{NSFontAttributeName: self.font};
    CGSize retSize = [self.text boundingRectWithSize:size
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attribute
                                             context:nil].size;
   
    return retSize;
}
@end
