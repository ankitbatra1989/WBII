//
//  AddBirthdayViewController.h
//  BuddayReminder
//
//  Created by Ankit on 30/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//
@protocol AddBirthdayDelegate <NSObject>
-(void)addBirthdaywithfriendsName:(NSString *)friendname andEmail:(NSString *)email andphonenumber:(NSString *)phoneNumber andImageData:(NSData *)imageData andBirthdate:(NSDate *)friendsbirthdate;

@end

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>


@interface AddBirthdayViewController : UIViewController<UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,ADBannerViewDelegate>
{
    
    __weak IBOutlet UIButton *addimageButton;
    __weak IBOutlet UIImageView *addImage;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITextField *phoneTextfield;

    __weak IBOutlet UITextField *phonePrefixTextField;
    __weak IBOutlet UITextField *emailTextField;

    __weak IBOutlet UIView *doneButtonView;
    __weak IBOutlet UIScrollView *bgScrollView;

    __weak IBOutlet UIButton *birthdayButton;
    __weak IBOutlet UIDatePicker *birthdatePicker;
    __unsafe_unretained id <AddBirthdayDelegate> delegate;

    __weak IBOutlet ADBannerView *bannerView;

}
@property (nonatomic, assign) id <AddBirthdayDelegate> delegate;
- (IBAction)addButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)birthdayButtonClicked:(UIButton *)sender;
- (IBAction)addImageTapped:(UIButton *)sender;
- (IBAction)doneButtonTapped:(UIButton *)sender;
@property(nonatomic,strong)UITextField *currenttextfield;
@end
