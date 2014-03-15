//
//  FriendTableViewCustomCell.m
//  BuddayReminder
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "FriendTableViewCustomCell.h"

@implementation FriendTableViewCustomCell

@synthesize friendName = _friendName;
@synthesize friendsPhotu = _friendsPhotu;
@synthesize friendAge = _friendAge;
@synthesize buddayLabel = _buddayLabel;
@synthesize inLabel = _inLabel;
@synthesize daysLeft = _daysLeft;
@synthesize bDate = _bDate;

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

@end
