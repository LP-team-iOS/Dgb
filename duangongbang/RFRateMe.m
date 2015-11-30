//
//  RFRateMe.m
//  RFRateMeDemo
//
//  Created by Ricardo Funk on 1/2/14.
//  Copyright (c) 2014 Ricardo Funk. All rights reserved.
//

#import "RFRateMe.h"
#import "UIAlertView+NSCookbook.h"

#define kNumberOfDaysUntilShowAgain 3
#define kAppStoreAddress @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=979141222&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"
#define kAppName @"短工邦"

@implementation RFRateMe

+(void)showRateAlert {
    
    //If rate was completed, we just return if True
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RateCompleted"];
    if (rateCompleted) return;
    
    //Check if the user asked not to be prompted again for 3 days (remind me later)
    BOOL remindMeLater = [[NSUserDefaults standardUserDefaults] boolForKey:@"RemindMeLater"];
    
    if (remindMeLater) {
        
        NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSString *start = [[NSUserDefaults standardUserDefaults] objectForKey:@"StartDate"];
        NSString *end = [DateFormatter stringFromDate:[NSDate date]];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yyyy-MM-dd"];
        NSDate *startDate = [f dateFromString:start];
        NSDate *endDate = [f dateFromString:end];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                            fromDate:startDate
                                                              toDate:endDate
                                                             options:0];
        
        if ((long)[components day] <= kNumberOfDaysUntilShowAgain) return;
        
    }
    
    //Show rate alert
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(kAppName, @"")
                                                        message:[NSString stringWithFormat:@"如果您喜欢%@,请稍微花费几分钟时间对我们的应用进行评价。感谢您的支持!",kAppName]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"残忍拒绝", @"")
                                              otherButtonTitles:NSLocalizedString(@"马上评价", @""),NSLocalizedString(@"下次提醒",@""), nil];
    
    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        switch (buttonIndex) {
            case 0:
                
                LOG(@"No, thanks");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                break;
            case 1:
                
                LOG(@"Rate it now");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RateCompleted"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreAddress]];
                
                break;
            case 2:
                
                LOG(@"Remind me later");
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *now = [NSDate date];
                [[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:now] forKey:@"StartDate"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RemindMeLater"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                break;
        }
    }];
}

+(void)showRateAlertAfterTimesOpened:(int)times {
    //Thanks @kylnew for feedback and idea!
    
    BOOL rateCompleted = [[NSUserDefaults standardUserDefaults] boolForKey:@"RateCompleted"];
    if (rateCompleted) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger timesOpened = [defaults integerForKey:@"timesOpened"];
    [defaults setInteger:timesOpened+1 forKey:@"timesOpened"];
    [defaults synchronize];
    LOG(@"App has been opened %ld times", (long)[defaults integerForKey:@"timesOpened"]);
    if([defaults integerForKey:@"timesOpened"] >= times){
        [RFRateMe showRateAlert];
    }


}

@end
