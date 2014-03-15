//
//  AppDelegate.m
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//
NSString *const BRSessionStateChangedNotification =
@"com.facebook.BirthdayReminder:BRSessionStateChangedNotification";

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GetContactsViewController.h"
#import <RevMobAds/RevMobAds.h>


@implementation AppDelegate
{
    UIStoryboard*  sb;
}
@synthesize navController = _navController;
@synthesize mainViewController = _mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    sb  = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    self.mainViewController = [sb instantiateViewControllerWithIdentifier:@"ViewController"];
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController:self.mainViewController];
    self.window.rootViewController = self.navController;
    // Override point for customization after application launch.
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
        [self.window makeKeyAndVisible];

    } else {
        // No, display the login page.
        [self.window makeKeyAndVisible];
        [self showLoginView];
    }
    //Rev Mob
     [RevMobAds startSessionWithAppID:@"529ff331172e773152000019"];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Handles Callback from Fb iOS app

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"Low memory Warning");
}

#pragma mark - showLoginView (Shows getContactsViewController modally if FBSession not open) 
- (void)showLoginView
{
    UIViewController *topViewController = [self.navController topViewController];
    UIViewController *modalViewController = [topViewController presentedViewController];

//    UIStoryboard*  sb  = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[GetContactsViewController class]]) {
        GetContactsViewController* loginViewController = [sb instantiateViewControllerWithIdentifier:@"GetContactsViewController"];
        [topViewController presentViewController:loginViewController animated:NO completion:nil];

    } else {
        GetContactsViewController* loginViewController = (GetContactsViewController*)modalViewController;
        [loginViewController loginFailed];
    }
}


#pragma mark - sessionStateChanged

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
        {
            UIViewController *topViewController = [self.navController topViewController];
            if ([[topViewController presentedViewController] isKindOfClass:[GetContactsViewController class]])
            {
              //  [topViewController dismissModalViewControllerAnimated:YES];
                [topViewController dismissViewControllerAnimated:YES completion:^{}];
            }
        }
            break;
        case FBSessionStateClosed:
        
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.navController popToRootViewControllerAnimated:NO];
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:BRSessionStateChangedNotification
     object:session];
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - openSession(Opens Fb Sesion With specific permissions)

- (void)openSession
{
    NSArray *permissionsArray = [NSArray arrayWithObjects:@"email",@"friends_about_me",@"friends_birthday",@"user_birthday",@"user_interests",@"basic_info",@"read_stream", nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissionsArray
                                       allowLoginUI:YES
                                        completionHandler:
    ^(FBSession *session,FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

#pragma mark - local notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}


@end
