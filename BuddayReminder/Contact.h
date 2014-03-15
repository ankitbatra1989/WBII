//
//  Contact.h
//  BuddayReminder
//
//  Created by Ankit on 25/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Contact : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) NSNumber * daysleft;
@property (nonatomic, retain) NSString * emailid;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSDate * upcomingbirthdate;
@property (nonatomic, retain) NSString * phoneno;

@end
