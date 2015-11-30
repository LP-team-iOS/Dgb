//
//  DetailViewCell.h
//  duangongbang
//
//  Created by ljx on 15/10/22.
//  Copyright © 2015年 duangongbang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbClassifyName;
@property (weak, nonatomic) IBOutlet UILabel *lbPriceUnit;
@property (weak, nonatomic) IBOutlet UILabel *lbSex;
@property (weak, nonatomic) IBOutlet UILabel *lbPayMethod;
@property (weak, nonatomic) IBOutlet UILabel *lbWorkDate;
@property (weak, nonatomic) IBOutlet UILabel *lbStreetName;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
