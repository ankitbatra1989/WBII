//
//  GetContactsViewController.m
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "GetContactsViewController.h"
#import "AppDelegate.h"
#import "InternetCheck.h"
#import <iAd/iAd.h>

@interface GetContactsViewController ()

@end

@implementation GetContactsViewController
@synthesize  AppLabel = _AppLabel;
//@synthesize bannerView = _bannerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Adding BannerView
       // Optional to set background color to clear color
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [bannerView setDelegate:self];
    
    [InternetCheck sharedInstance];

    [fbLoginButton setAlpha:0.0];
    [self.AppLabel setAlpha:0.0];
    [requiredLabel setAlpha:0.0];
	// Do any additional setup after loading the view.
    [UIView animateWithDuration:3.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.AppLabel setAlpha:1.0];
                        // self.AppLabel.textColor = [UIColor lightGrayColor];

                     }
                     completion:^(BOOL finished){
                        
                         [UIView animateWithDuration:2.0f delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                             // self.AppLabel.frame = CGRectMake(75 , 75, 170, 160);
                                              [fbLoginButton setAlpha:1.0];
                                              [requiredLabel setAlpha:0.8];

                                          }
                                          completion:^(BOOL finished)
                          {
                              
                          }];
                         


                     }];
    

    
    

    
//    UIFont *font1 = [UIFont fontWithName:@"Oreos" size:20.0];
//    self.AppLabel.font = font1;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
    {
        [bannerView setHidden:YES];
        [bannerView setDelegate:nil];

    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getFriendsInfoFromFB:(UIButton *)sender {
    
    if ([InternetCheck sharedInstance].internetWorking)
    {
        [self.loadingIndicator startAnimating];
        [(AppDelegate *)[UIApplication sharedApplication].delegate openSession];

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!!" message:@"Please check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
 
    }
   }



- (void)loginFailed
{
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
    [self.loadingIndicator stopAnimating];
}

- (void)viewDidUnload {
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading : %@",[error description]);
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
    
}

@end
