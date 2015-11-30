//
//  LabelPlacing.m
//  duangongbang
//
//  Created by Chen Haochuan on 15/8/17.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import "LabelPlacing.h"

@implementation LabelPlacing

+ (void)thtLabelPlacingWith:(UILabel *)label {
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:label.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle1.lineBreakMode = NSLineBreakByCharWrapping;
    [paragraphStyle1 setLineSpacing:4];
    [paragraphStyle1 setFirstLineHeadIndent:8];
    [paragraphStyle1 setHeadIndent:8];
//    [paragraphStyle1 setTailIndent:8];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [label.text length])];
    [label setAttributedText:attributedString1];
}

@end
