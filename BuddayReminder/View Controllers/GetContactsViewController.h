//
//  GetContactsViewController.h
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface GetContactsViewController : UIViewController<ADBannerViewDelegate>
{
    
    __weak IBOutlet UIImageView *bgImage;
    __weak IBOutlet UILabel *AppLabel;
    __weak IBOutlet UIButton *fbLoginButton;
    __weak IBOutlet ADBannerView *bannerView;

    __weak IBOutlet UILabel *requiredLabel;

}
- (IBAction)getFriendsInfoFromFB:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *AppLabel;

- (void)loginFailed;
//@property (weak, nonatomic) IBOutlet ADBannerView *bannerView;

@end
