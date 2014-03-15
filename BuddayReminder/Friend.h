//
//  Friend.h
//  BuddayReminder
//
//  Created by Ankit on 27/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) NSNumber * daysleft;
@property (nonatomic, retain) NSString * fbid;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSString * photourl;
@property (nonatomic, retain) NSDate * upcomingbirthdate;

@end
