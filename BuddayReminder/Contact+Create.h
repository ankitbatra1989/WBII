//
//  Contact+Create.h
//  BuddayReminder
//
//  Created by Ankit on 24/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "Contact.h"

@interface Contact (Create)

+(Contact *)contactWithInfo:(NSDictionary *)contactInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)removeContactWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)refreshFriendDatabase:(NSManagedObjectContext *)context;

@end
