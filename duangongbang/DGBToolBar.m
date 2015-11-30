//
//  DGBToolBar.m
//  TestAll
//
//  Created by Chen Haochuan on 15/8/15.
//  Copyright (c) 2015年 Chen Haochuan. All rights reserved.
//

#import "DGBToolBar.h"

@interface DGBToolBar(){
    NSArray *_titlesArray;
    NSArray *_imagesArray;
    NSInteger _buttonCount;
    
}

@end

@implementation DGBToolBar

@synthesize bgColor;
@synthesize font;
@synthesize textColor;
@synthesize titleEdgeInsets;
@synthesize imageEdgeInsets;
@synthesize labelWidth;

- (instancetype)initWithRect:(CGRect)rect {
    self = [super init];
    if (self) {
        self.frame = rect;
        self.backgroundColor = bgColor;
        self.font = [UIFont systemFontOfSize:12.0];
        [self setBgColor:[UIColor blackColor]];
    }
    return self;
}
#pragma mark - Getter
- (UIColor *)backgroundColor {
    if (!bgColor) {
        bgColor = [UIColor grayColor];
    }
    return bgColor;
}

- (UIColor *)textColor {
    if (!textColor) {
        textColor = [UIColor whiteColor];
    }
    return textColor;
}

#pragma mark - Setter
- (void)setDataSource:(id<DGBToolBarDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    if ([_dataSource respondsToSelector:@selector(numberOfToolBar:)]) {
        _buttonCount = [_dataSource numberOfToolBar:self];
    }else {
        _buttonCount = 0;
    }
    
    if ([_dataSource respondsToSelector:@selector(titlesOfToolBar:)]) {
        _titlesArray = [_dataSource titlesOfToolBar:self];
    }else {
        _titlesArray = nil;
    }
    
    [self addButtonWithNum:_buttonCount animate:YES];
}

- (void)setBgColor:(UIColor *)_backgroundColor {
    bgColor = _backgroundColor;
    self.backgroundColor = _backgroundColor;
}

#pragma mark - Methods
- (void)addButtonWithNum:(NSInteger)num animate:(BOOL)animate{
    for (int i = 0; i < num; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.frame.size.width, BUTTON_ORIGIN_Y, BUTTON_WIDTH, BUTTON_HEIGHT);
        btn.layer.cornerRadius = BUTTON_HEIGHT / 2;
        btn.backgroundColor = [_dataSource colorOfToolBar:i];
        
        if ([_dataSource imageOfToolBar:i]) {
            //button上子控件的垂直对齐方式
            btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [btn setImage:[_dataSource imageOfToolBar:i] forState:UIControlStateNormal];
        }
        
        btn.titleLabel.font = font;
        [btn setTitle:[_titlesArray objectAtIndex:i] forState:UIControlStateNormal];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        labelWidth = btn.titleLabel.frame.size.width;
        
        //设置图标title和图标位置
        if ([_dataSource imageOfToolBar:i] && ![[_titlesArray objectAtIndex:i] isEqualToString:@""]) {
            btn.titleEdgeInsets = titleEdgeInsets;
            btn.imageEdgeInsets = imageEdgeInsets;
        }
        
        CGFloat originX = self.frame.size.width / (num * 2) * (1 + i * 2);
        [btn setTag:i];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        //button出现动画spring
        if (animate) {
            [UIView animateWithDuration:ANIMATION_TIME delay:i * (ANIMATION_TIME / num) usingSpringWithDamping:SPRING_DAMPING initialSpringVelocity:SPRING_VELOCITY options:UIViewAnimationOptionCurveEaseInOut animations:^{
                btn.center = CGPointMake(originX, BUTTON_ORIGIN_Y + BUTTON_HEIGHT * 0.5);
            } completion:^(BOOL finished) {
                
            }];
        }else {
            btn.center = CGPointMake(originX, BUTTON_ORIGIN_Y + BUTTON_HEIGHT * 0.5);
        }
        
    }
}

-(void)reloadData {
    
    for (UIButton *btn in [self subviews]) {
        [btn removeFromSuperview];
    }
    
    if ([_dataSource respondsToSelector:@selector(numberOfToolBar:)]) {
        _buttonCount = [_dataSource numberOfToolBar:self];
    }else {
        _buttonCount = 0;
    }
    
    if ([_dataSource respondsToSelector:@selector(titlesOfToolBar:)]) {
        _titlesArray = [_dataSource titlesOfToolBar:self];
    }else {
        _titlesArray = nil;
    }
    
    [self addButtonWithNum:_buttonCount animate:NO];

}

- (void)buttonAction:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolBar:didSelectAtIndexPath:)]) {
        [self.delegate toolBar:self didSelectAtIndexPath:button.tag];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@end
