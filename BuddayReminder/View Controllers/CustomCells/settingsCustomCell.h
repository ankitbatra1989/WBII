//
//  settingsCustomCell.h
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchDelegate <NSObject>
-(void)switchStateChanged:(BOOL)isOn;
@end

@interface settingsCustomCell : UITableViewCell
{
        __unsafe_unretained id <SwitchDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (nonatomic, assign) id <SwitchDelegate> delegate;
- (IBAction)notificationsValueChanged:(UISwitch *)sender;

@end
