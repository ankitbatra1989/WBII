//
//  AddBirthdayViewController.m
//  BuddayReminder
//
//  Created by Ankit on 30/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "AddBirthdayViewController.h"
#import "InternetCheck.h"
#import <RevMobAds/RevMobAds.h>


@interface AddBirthdayViewController ()

@end

@implementation AddBirthdayViewController
@synthesize currenttextfield = _currenttextfield;
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

	// Do any additional setup after loading the view.
    [self.navigationController setTitle:@"Add Birthday"];
    [self.navigationController setNavigationBarHidden:NO];
    [bgScrollView setContentSize:CGSizeMake(320, 800)];
    [birthdatePicker setMaximumDate:[NSDate date]];
    bgScrollView.contentOffset = CGPointMake(0, 30);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //
    
    [bannerView setBackgroundColor:[UIColor clearColor]];
    [bannerView setDelegate:self];
    //
    if (![InternetCheck sharedInstance].internetWorking)
        
    {
        [bannerView setHidden:YES];
       // birthdatePicker.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-216, 320, 216);
    }
    else
    {
        [bannerView setHidden:NO];
        //birthdatePicker.frame = CGRectMake(0,[[UIScreen mainScreen] bounds].size.height-216-50 , 320, 216);
    }
    
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

#pragma mark - Buttons Tapped

- (IBAction)addButtonPressed:(UIBarButtonItem *)sender
{
    if (![nameTextField.text isEqualToString:@""] && ![birthdayButton.currentTitle isEqualToString:@""] && ![phoneTextfield.text isEqualToString:@""])
    {
        [self.delegate addBirthdaywithfriendsName:nameTextField.text andEmail:emailTextField.text andphonenumber:[NSString stringWithFormat:@"%@%@",phonePrefixTextField.text,phoneTextfield.text] andImageData:UIImageJPEGRepresentation(addImage.image, 0.0)  andBirthdate:birthdatePicker.date];
        [self.navigationController popViewControllerAnimated:YES];

    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Sorry!!" message:@"Please enter all required fields." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    
}

- (IBAction)birthdayButtonClicked:(UIButton *)sender
{
    [nameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [phoneTextfield resignFirstResponder];
    [doneButtonView setHidden:YES];
    [phonePrefixTextField resignFirstResponder];
    bgScrollView.contentOffset = CGPointMake(0, 50);
   // doneButtonView.frame = CGRectMake(0,279, 320, 40);
    
    [birthdatePicker setHidden:NO];
    [doneButtonView setHidden:NO];
}

- (IBAction)addImageTapped:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"Cancel Button"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Use Camera", @"Use Existing Photo", nil];
    [actionSheet showInView:self.view];

}

- (IBAction)doneButtonTapped:(UIButton *)sender
{
    [nameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    if (self.currenttextfield == phoneTextfield || self.currenttextfield == phonePrefixTextField)
    {
        [self.currenttextfield resignFirstResponder];
        [doneButtonView setHidden:YES];
        [birthdatePicker setHidden:YES];

    }
    else
    {
        [phonePrefixTextField resignFirstResponder];
        [phoneTextfield resignFirstResponder];
        [birthdatePicker setHidden:YES];
        [doneButtonView setHidden:YES];
    
        // populating birthdate textfield
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"d MMMM YYYY"]; //24hr time format
        NSString *dateString = [outputFormatter stringFromDate:birthdatePicker.date];
        [birthdayButton setTitle:[NSString stringWithFormat:@" %@", dateString] forState:UIControlStateNormal];
        bgScrollView.contentOffset = CGPointMake(0, 0);
    }

}

#pragma mark TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
 
    if(textField.tag == 13)
    {
        
        NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789+"];
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        int charCount = [newString length];
        if ([string isEqualToString:@""])
        {
            return YES;
        }
        
        if ([newString rangeOfCharacterFromSet:[numSet invertedSet]].location != NSNotFound || charCount > 3) {
            return NO;
        }
        phonePrefixTextField.text = newString;
        
        return NO;
        
    }
    else if(textField.tag == 102)
    {
        NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        int charCount = [newString length];
        
        if ([string isEqualToString:@""])
        {
            return YES;
        }
        
        if ([newString rangeOfCharacterFromSet:[numSet invertedSet]].location != NSNotFound || charCount > 10) {
            return NO;
        }
        
        
        phoneTextfield.text = newString;
        
        return NO;
    }
    else
        return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [bgScrollView scrollsToTop];
	// the user pressed the "Done" button, so dismiss the keyboard
    bgScrollView.contentOffset = CGPointMake(0, 0);
    //doneButtonView.frame = CGRectMake(0,279, 320, 40);
	[textField resignFirstResponder];
    if ([InternetCheck sharedInstance].internetWorking)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]showBanner];
        }
    }
	return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([InternetCheck sharedInstance].internetWorking)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]hideBanner];
        }
    }
    self.currenttextfield = textField;
    [doneButtonView setHidden:YES];
    if (textField == nameTextField) {
        bgScrollView.contentOffset = CGPointMake(0,80);

    }
    else if(textField == phonePrefixTextField || textField == phoneTextfield)
    {
        bgScrollView.contentOffset = CGPointMake(0, 130);
       // doneButtonView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 256, 320, 40);
        [doneButtonView setHidden:NO];
        
    }
    else if(textField == emailTextField)
    {
        bgScrollView.contentOffset = CGPointMake(0, 180);
        
    }
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

#pragma mark Valid Email
-(BOOL) validEmail:(NSString*) emailString {
	
	NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$";
	NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
	NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
	if (regExMatches == 0) {
		return NO;
	} else
		return YES;
}



#pragma mark - UIActionSheet delegate Camera
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"buttonIndex %d",buttonIndex);
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
	if(buttonIndex == 0)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
       // [self presentModalViewController:picker animated:YES];
        [self presentViewController:picker animated:YES completion:^{
            
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                if ([InternetCheck sharedInstance].internetWorking)
                {
                    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
                    {
                        [[RevMobAds session]hideBanner];
                    }
                }            }
        
        }];
	} else if(buttonIndex == 1){
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:picker animated:YES completion:^{
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                if ([InternetCheck sharedInstance].internetWorking)
                {
                    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
                    {
                        [[RevMobAds session]hideBanner];
                    }
                }
            }
        }];
    }
}

#pragma mark - UIImagePickerController delegate

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    //NSLog(@"imagePickerControllerDidCancel");
  //  [picker dismissModalViewControllerAnimated:YES];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([InternetCheck sharedInstance].internetWorking)
        {
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                [[RevMobAds session]showBanner];
            }
        }
    }];
    //[topBar setHidden:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([InternetCheck sharedInstance].internetWorking)
        {
            if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
            {
                [[RevMobAds session]showBanner];
            }
        }
    }];
    addImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [addimageButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading : %@",[error description]);
    [[RevMobAds session] showBanner];
// birthdatePicker.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height-216, 320, 216);

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
