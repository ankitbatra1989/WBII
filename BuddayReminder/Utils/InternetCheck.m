//
//  InternetCheck.m
//  SnaplionIOSApp
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.//

#import "InternetCheck.h"
#import "Reachability.h"

@implementation InternetCheck


+ (InternetCheck*) sharedInstance
{
    static InternetCheck *instance = nil;
    
    if (!instance)
    {
        @synchronized (self)
        {
            if (!instance) {
                instance = [[InternetCheck alloc] init];
                 [instance initializeReachabilityObject];
                
            }
            
        }
        
    }
    return instance;

}

#pragma mark -
#pragma mark Reachability Class


-(void) initializeReachabilityObject
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    hostReach = [Reachability reachabilityWithHostName:@"www.google.com"];
    [hostReach startNotifier];
	[self updateInterfaceWithReachability: hostReach];
}

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            self.internetWorking=NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            self.internetWorking=YES;
            break;
        }
        case ReachableViaWiFi:
        {
            self.internetWorking=YES;
            break;
        }
    }
    
}


- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
	[self updateInterfaceWithReachability: curReach];
}

@end
