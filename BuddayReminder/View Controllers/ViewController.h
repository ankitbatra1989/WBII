//
//  ViewController.h
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>
#import "SettingsViewController.h"
#import "AddBirthdayViewController.h"
#import <iAd/iAd.h>
#import <RevMobAds/RevMobAds.h>



typedef enum
{
    FacebookMode,
    contactMode
}TableViewMode;


@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UISearchBarDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,SettingsActionDelegate,AddBirthdayDelegate,UIAlertViewDelegate,ADBannerViewDelegate,RevMobAdsDelegate>
{
    __weak IBOutlet UIView *contactsBgView;
    __weak IBOutlet UIView *friendsbgView;
    __weak IBOutlet UIButton *fbButton;
    __weak IBOutlet UIButton *contactsButton;
    __weak IBOutlet UISearchBar *searchbar1;
    __weak IBOutlet UIView *cellMagnifiedView;
    __weak IBOutlet UIView *overlayView;
    __weak IBOutlet UILabel *populatingLabel;
    
    //inside cellMagnifiedView
    __weak IBOutlet UILabel *inLabel;
    __weak IBOutlet UILabel *age;
    __weak IBOutlet UIImageView *profilepic;
    __weak IBOutlet UILabel *name;
    __weak IBOutlet UILabel *bdate;
    __weak IBOutlet UIButton *textButton;
    __weak IBOutlet UIButton *emailButton;
    __weak IBOutlet UIButton *fbPostButton;
    __weak IBOutlet UILabel *daysLeft;
    __weak IBOutlet UIView *actionButtonsBgView;
    __weak IBOutlet UIButton *callButton;
    
    //ADD BANNER
    
    __weak IBOutlet ADBannerView *bannerView;
    
    NSArray *fetchedObjects;
    NSArray *localNotifObjectsArray;
    NSFetchedResultsController *fetchedResulstController;
    //bar buttons

    __weak IBOutlet UIBarButtonItem *addButton;
    __weak IBOutlet UIButton *settingsButton;
}
@property (weak, nonatomic) IBOutlet UITableView *UpcomingBirthdaysTableView;
@property (weak, nonatomic) IBOutlet UILabel *myUsername;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *myProfilePic;
@property(nonatomic,strong) UIManagedDocument *friendsDatabase;
@property (nonatomic,strong)  NSArray *fetchedObjects;
@property (nonatomic,strong)  NSArray *localNotifObjectsArray;
@property (nonatomic,assign)TableViewMode viewMode;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *populatingDataActivityIndicator;


- (IBAction)FbButtonBapped:(UIButton *)sender;
- (IBAction)contactsButtonTapped:(UIButton *)sender;
- (IBAction)logoutTapped:(UIButton *)sender;
- (IBAction)addEventTapped:(UIButton *)sender;
//inside cellMagnifiedView
- (IBAction)postOnWallClicked:(UIButton *)sender;
- (IBAction)backToFrndsList:(UIButton *)sender;
- (IBAction)smsButtonClicked:(UIButton *)sender;
- (IBAction)emailButtonClicked:(UIButton *)sender;
- (IBAction)callButtonClicked:(UIButton *)sender;
- (IBAction)settingsButtonTapped:(UIButton *)sender;


@property(nonatomic,strong) NSString *friendname;
@property(nonatomic,strong) NSString *birthdate;
@property(nonatomic,strong)NSString *friendsAgeString;
@property(nonatomic,strong)NSString *daysLeftToBday;
@property(nonatomic,strong) NSData *profilepicdata;
@property(nonatomic,strong)NSString *userfbid;
//Rev Mob
@property (nonatomic, strong)RevMobFullscreen *fullscreen;

//in case of contacts
@property(nonatomic,strong)NSString *emailId;
@property(nonatomic,strong)NSString *phoneNumber;


@end
