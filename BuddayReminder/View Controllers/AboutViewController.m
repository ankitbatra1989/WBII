//
//  AboutViewController.m
//  BuddayReminder
//
//  Created by Ankit on 30/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "AboutViewController.h"
#import <RevMobAds/RevMobAds.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

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
    
    //
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [bannerView setDelegate:self];

	// Do any additional setup after loading the view.
    self.navigationController.title = @"About";
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //check for receipt
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

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading : %@",[error description]);
    [[RevMobAds session] showBanner];

}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
    [[RevMobAds session] hideBanner];

}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
    
}

@end
