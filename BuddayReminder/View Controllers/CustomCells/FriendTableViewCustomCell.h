//
//  FriendTableViewCustomCell.h
//  BuddayReminder
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendTableViewCustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bDate;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property (weak, nonatomic) IBOutlet UILabel *buddayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendsPhotu;
@property (weak, nonatomic) IBOutlet UILabel *friendAge;
@property (weak, nonatomic) IBOutlet UILabel *daysLeft;
@property (weak, nonatomic) IBOutlet UILabel *inLabel;

@end
