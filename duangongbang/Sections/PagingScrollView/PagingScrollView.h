//
//  PagingScrollView.h
//  duangongbang
//
//  Created by ljx on 15/5/2.
//  Copyright (c) 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PagingScrollView;

@protocol PGScrollViewDelegete <NSObject>
@optional
- (void)scrollViewDidScroll:(PagingScrollView *)scrollView;

@end

@interface PagingScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic) CGFloat pageWidth;

@property (nonatomic) CGFloat pageHeight;

@property (assign,nonatomic)id<PGScrollViewDelegete>aDelegate;

@end
