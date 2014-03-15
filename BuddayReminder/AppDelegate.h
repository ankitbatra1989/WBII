//
//  AppDelegate.h
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//
extern NSString *const BRSessionStateChangedNotification;

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navController;
@property (strong, nonatomic) ViewController *mainViewController;


/** Method Name : openSession
    Arguments   : none
    Function    : opens Fb Session with permissions
    Returns     : void
 **/
- (void)openSession;

@end
