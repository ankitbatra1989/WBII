//
//  SettingsViewController.m
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "SettingsViewController.h"
#import "settingsCustomCell.h"
#import "ReminderOptionsViewController.h"
#import "AboutViewController.h"
#import "InternetCheck.h"
#import  <RevMobAds/RevMobAds.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize  delegate = _delegate;

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
	// Do any additional setup after loading the view.

    
    [remindertimepicker setAlpha:0.0];
    [remindertimepicker setHidden:YES];
    [doneView setAlpha:0.0];
    [doneView setHidden:YES];
    self.navigationController.title = @"Settings";
    [self.navigationController setNavigationBarHidden:NO];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@"< Back"
                                            style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                  action:@selector(handleBack:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
    
    

    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [bannerView setBackgroundColor:[UIColor clearColor]];
    if (![InternetCheck sharedInstance].internetWorking)
        
    {
        [bannerView setDelegate:nil];
       // [bannerView removeFromSuperview];
        [bannerView setHidden:YES];
        settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen]bounds].size.height-65);
    }
    else
    {
        //[self.view addSubview:bannerView];
        [bannerView setDelegate:self];
        [bannerView setHidden:NO];
        settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen] bounds].size.height-65-50);
    }

    //check for receipt
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
    {
        [bannerView setHidden:YES];
        settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen]bounds].size.height-65);
        [bannerView setDelegate:nil];


    }
}

- (void) handleBack:(id)sender
{
    // pop to root view controller
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate settingsApplied];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        return 3;
    }
    else if(section == 1)
        return 4;
    else
        return 2;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Notifications";
            break;
        case 1:
            sectionName = @"Actions";
            break;
            // ...
        case 2:
            sectionName = @"Miscellaneous";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"settingsCustomCell";
    settingsCustomCell *cell = (settingsCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell =[[settingsCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    cell.delegate = self;

    if (indexPath.section ==0)
    {
        [cell.actionButton setHidden:YES];
        [cell.title setHidden:NO];
        if (indexPath.row == 0)
        {
            [cell.reminderSwitch setHidden:NO];
            [cell.subtitle setHidden:YES];
            cell.title.text = @"Enable Notifications";
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.reminderSwitch setOn: [[NSUserDefaults standardUserDefaults]boolForKey:@"areNotificationsEnabled"]];
        }
        else if(indexPath.row == 1)
        {
            [cell.subtitle setHidden:NO];
            cell.title.text = @"Reminders";
            cell.subtitle.text = @"On Birthday";
            cell.subtitle.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Reminders"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            [cell.subtitle setHidden:NO];
            cell.title.text = @"Daily Notify Time";
            cell.subtitle.text = @"00:00 am";
            cell.subtitle.text =   [[NSUserDefaults standardUserDefaults]objectForKey:@"Daily Notify Time"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        }
    }
    else if(indexPath.section == 1)
    {
        [cell.subtitle setHidden:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cell.reminderSwitch setHidden:YES];
        if (indexPath.row == 0)
        {
            [cell.actionButton setHidden:NO];
            [cell.title setHidden:YES];
            [cell.actionButton setTitle:@"Logout From Facebook" forState:UIControlStateNormal];
        }
        else if(indexPath.row == 1)
        {
            [cell.actionButton setHidden:NO];
            [cell.title setHidden:YES];
            [cell.actionButton setTitle:@"Refresh All Data" forState:UIControlStateNormal];

        }
        else if(indexPath.row == 2)
        {
            [cell.actionButton setHidden:NO];
            [cell.title setHidden:YES];
            [cell.actionButton setTitle:@"Upgrade to Premium (No Ads)" forState:UIControlStateNormal];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                [cell.actionButton setEnabled:NO];
            }
            else
            {
                [cell.actionButton setEnabled:YES];
            }
        }
        else
        {
            [cell.actionButton setHidden:NO];
            [cell.title setHidden:YES];
            [cell.actionButton setTitle:@"Restore Completed Transaction" forState:UIControlStateNormal];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                [cell.actionButton setEnabled:NO];
            }
            else
            {
                [cell.actionButton setEnabled:YES];
            }
        }
    }
    else
    {
        [cell.reminderSwitch setHidden:YES];
        [cell.subtitle setHidden:YES];
        [cell.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        if (indexPath.row ==0)
        {
            [cell.title setHidden:YES];
            [cell.actionButton setTitle:@"Rate Us :)" forState:UIControlStateNormal];
            [cell.actionButton setHidden:NO];
            [cell.actionButton setEnabled:YES];
            cell.accessoryType = UITableViewCellAccessoryNone;

        }
        else
        {
            [cell.title setHidden:NO];
            cell.title.text = @"About Who's Birthday Is It?";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }
    return cell;
}


#pragma mark - TableView Delegate methods


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            //push Reminder options view controller
            ReminderOptionsViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReminderOptionsViewController"];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else if (indexPath.row == 0)
        {
        }
        else
        {
            // show picker view
            [doneView setAlpha:1.0];
            [remindertimepicker setAlpha:1.0];
            [remindertimepicker setHidden:NO];
            [doneView setHidden:NO];
        }
    }
    else if(indexPath.section == 2)
    {
        if (indexPath.row ==1)
        {
            AboutViewController *vc = [ self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
            [self.navigationController pushViewController:vc animated:YES];
    
        }
    }
}


#pragma mark - Switch Delegate Method

-(void)switchStateChanged:(BOOL)isOn
{
     NSLog(@"is on %hhd",isOn);
    [[NSUserDefaults standardUserDefaults]setBool:isOn forKey:@"areNotificationsEnabled"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}
#pragma mark - Reminder Options Delegate Method


-(void)reminderOptionSelected:(NSString *)reminderOption
{
    [[NSUserDefaults standardUserDefaults]setObject:reminderOption forKey:@"Reminders"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    settingsCustomCell *cell = (settingsCustomCell *)[settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell.subtitle.text = reminderOption;

}

- (IBAction)doneButtonClicked:(UIButton *)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm a"]; //24hr time format
    NSString *dateString = [outputFormatter stringFromDate:remindertimepicker.date];
    [[NSUserDefaults standardUserDefaults]setObject:dateString forKey:@"Daily Notify Time"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    //hide picker view
    [doneView setAlpha:0.0];
    [remindertimepicker setHidden:YES];
    [doneView setHidden:YES];
    settingsCustomCell *cell = (settingsCustomCell *)[settingsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    cell.subtitle.text = dateString;

}

-(void)actionButtonTapped:(UIButton *)sender
{
    if ([sender.currentTitle isEqualToString:@"Logout From Facebook"]) {
        [self.delegate logoutTapped];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([sender.currentTitle isEqualToString:@"Refresh All Data"])
    {
        [self.delegate refreshButtonTapped];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if ([sender.currentTitle isEqualToString:@"Upgrade to Premium (No Ads)"])
    {
        NSURL * url = [[NSBundle mainBundle] URLForResource:@"product_ids"
                                              withExtension:@"plist"];
        NSArray * productIdentifiers = [NSArray arrayWithContentsOfURL:url];

        [self validateProductIdentifiers:productIdentifiers];
    }
    else if ([sender.currentTitle isEqualToString:@"Rate Us :)"])
    {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id770160022"]];
    }
    else
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
    

}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading : %@",[error description]);
    // [bannerView removeFromSuperview];
    
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


#pragma mark - revmob delegate
- (void)revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Ad failed: %@", error);
    [bannerView setHidden:YES];
    settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen]bounds].size.height-65);
}

// Custom method
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                         initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

#pragma mark-SKProductsRequestDelegate protocol method

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
     [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    self.products = response.products;
    
    for (NSString * invalidProductIdentifier in response.invalidProductIdentifiers) {
        // Handle any invalid product identifiers.
        NSLog(@"Invalid product id: %@" , invalidProductIdentifier);

    }
    
    [self displayStoreUI]; // Custom method
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    
    NSLog(@"Failed to load list of products.");
}


-(void)displayStoreUI
{
    UIAlertView *iapAlert =[[UIAlertView alloc]initWithTitle:@"Confirm Your In-App Purchase" message:@"You are about to buy the Premium (no ads) version of the app?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
    [iapAlert show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        SKProduct *product = [self.products objectAtIndex:0];
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        if ([SKPaymentQueue canMakePayments]) {
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
        else
        {
            UIAlertView *regretalert =[[UIAlertView alloc]initWithTitle:@"Regret" message:@"You're not allowed to make payments" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [regretalert show];

        }
    }
}

#pragma mark-Payment observer deledate methoids

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    // handle payment cancellation
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // handle the payment transaction actions for each state
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}



- (void) completeTransaction: (SKPaymentTransaction *)transaction;
{
    // Do whatever you need to do to provide the service/subscription purchased
   
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    NSLog(@"Transaction finished");
    if(transaction.originalTransaction)
    {
        NSLog(@"Just restoring the transaction");
    }
    else
    {
        // Record the transaction
        NSLog(@"First time transaction");
        NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
        NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
        [storage setObject:receipt forKey:@"receipt"];
        [storage synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Successful"
                                                        message:@"Thank you for purchasing the premium no ads version of our app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        //removing ads on purchase
        [bannerView setHidden:YES];
        settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen]bounds].size.height-65);
        [bannerView setDelegate:nil];
        [[RevMobAds session]hideBanner];


    }
    
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    // Record the transaction
    //...
    
    // Do whatever you need to do to provide the service/subscription purchased
    //...
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
    [storage setObject:receipt forKey:@"receipt"];
    [storage synchronize];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Eror Des %@",transaction.error.localizedDescription);
        // Optionally, display an error here.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Unsuccessful"
                                                        message:@"Your purchase failed. Please try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"restore transaction");
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptUrl];
    [[NSUserDefaults standardUserDefaults] setObject:receipt forKey:@"receipt"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Transaction Restored"
                                                    message:@"Your purchase has been restored to your phone."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    //removing banner on restoring transaction
    [bannerView setHidden:YES];
    settingsTableView.frame = CGRectMake(0,65,320, [[UIScreen mainScreen]bounds].size.height-65);
    [bannerView setDelegate:nil];
    [[RevMobAds session]hideBanner];



    
}



@end
