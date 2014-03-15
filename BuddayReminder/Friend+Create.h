//
//  Friend+Create.h
//  BuddayReminder
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "Friend.h"

@interface Friend (Create)

+(Friend *)friendWithInfo:(NSDictionary *)friendInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)removeFriendWithid:(NSString *)fbid inManagedObjectContext:(NSManagedObjectContext *)context;
+(void)refreshFriendDatabase:(NSManagedObjectContext *)context;

@end
