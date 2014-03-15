//
//  ReminderOptionsViewController.h
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

@protocol RemiderOptionDelegate <NSObject>
-(void)reminderOptionSelected:(NSString *)reminderOption;
@end

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface ReminderOptionsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,ADBannerViewDelegate>
{
    __unsafe_unretained id <RemiderOptionDelegate> delegate;

    //ADD BANNER
    
    __weak IBOutlet ADBannerView *bannerView;

}
@property (nonatomic, assign) id <RemiderOptionDelegate> delegate;

@end
