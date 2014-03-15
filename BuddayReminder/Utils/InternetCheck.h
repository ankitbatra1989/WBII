//
//  InternetCheck.h
//  SnaplionIOSApp
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//  Class checks whether the device is connected to internet or not

#import <Foundation/Foundation.h>
@class Reachability;
@interface InternetCheck : NSObject
{
     Reachability* hostReach;
}


@property(nonatomic,assign) BOOL internetWorking;

/**
 *	@functionName	: sharedInstance
 *	@parameters		:
 *	@return			: Object of the class
 *	@description	: Creates the singleton object of the class
 */
+ (InternetCheck*) sharedInstance;
@end
