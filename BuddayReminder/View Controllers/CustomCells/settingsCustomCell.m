//
//  settingsCustomCell.m
//  BuddayReminder
//
//  Created by Ankit on 29/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "settingsCustomCell.h"

@implementation settingsCustomCell

@synthesize delegate = _delegate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize actionButton = _actionButton;
@synthesize reminderSwitch = _reminderSwitch;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)notificationsValueChanged:(UISwitch *)sender
{
    NSLog(@"Switch State %hhd",sender.isOn);
    [self.delegate switchStateChanged:sender.isOn];
}
@end
