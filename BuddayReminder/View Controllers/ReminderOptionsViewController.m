//
//  ReminderOptionsViewController.m
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "ReminderOptionsViewController.h"
#import <RevMobAds/RevMobAds.h>

@interface ReminderOptionsViewController ()
{
    NSArray * optionsArray;
}

@end

@implementation ReminderOptionsViewController
@synthesize delegate = _delegate;

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
        [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setTitle:@"Reminder Options"];
    optionsArray = [[NSArray alloc]initWithObjects:@"On Birthday",@"1 day before birthday",@"3 days before birthday",@"7 days before birthday", nil];
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


#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 4;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"reminderoptionscell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.textLabel.text = [optionsArray objectAtIndex:indexPath.row];
    

    return cell;
}


#pragma mark - TableView Delegate methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedcell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self.delegate reminderOptionSelected:selectedcell.textLabel.text];
    [self.navigationController popViewControllerAnimated:YES];
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
