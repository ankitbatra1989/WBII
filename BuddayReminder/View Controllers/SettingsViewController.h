//
//  SettingsViewController.h
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//


@protocol SettingsActionDelegate <NSObject>

-(void)refreshButtonTapped;
-(void)logoutTapped;
-(void)settingsApplied;

@end

#import <UIKit/UIKit.h>
#import "settingsCustomCell.h"
#import "ReminderOptionsViewController.h"
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>
#import <RevMobAds/RevMobAds.h>


@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDataSource,SwitchDelegate,RemiderOptionDelegate,ADBannerViewDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate,RevMobAdsDelegate>
{
    
    __weak IBOutlet UITableView *settingsTableView;
    __weak IBOutlet UIView *doneView;
    __weak IBOutlet UIDatePicker *remindertimepicker;
    __unsafe_unretained id <SettingsActionDelegate> delegate;
    //ADD BANNER
    __weak IBOutlet ADBannerView *bannerView;

    
}
@property (nonatomic, assign) id <SettingsActionDelegate> delegate;

- (IBAction)doneButtonClicked:(UIButton *)sender;

//sk products
@property (nonatomic,strong)NSArray *products;

//Payment observer methods
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;

@end
