//
//  Friend+Create.m
//  BuddayReminder
//
//  Created by Ankit on 18/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "Friend+Create.h"


@implementation Friend (Create)

+(Friend *)friendWithInfo:(NSDictionary *)friendInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Friend *friend = nil;
    
    //checking if that same photo already exists in database (by quering db)
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.predicate = [NSPredicate predicateWithFormat:@"(fbid = %@)",[friendInfo objectForKey:@"fbid"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"daysleft" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(!matches)
    {
        //handle error..matches query shouldnot return nil
        NSLog(@"Query error");
    }
    else if ([matches count]>1)
    {
        //handle error..matches count cant be greater than 1..that means more than 1 unique friend exits in db
        NSLog(@"MAtches > 1");
    }
    else if ([matches count] == 0)
    {
        friend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
        friend.fullname = [friendInfo objectForKey:@"fullname"];
        friend.photourl =[friendInfo objectForKey:@"photourl"];
        friend.birthdate =[friendInfo objectForKey:@"birthdate"];
        friend.age = [friendInfo objectForKey:@"age"];
        friend.daysleft = [friendInfo objectForKey:@"daysleft"];
        friend.upcomingbirthdate = [friendInfo objectForKey:@"upcomingbirthdate"];
        friend.photoData =[NSData dataWithContentsOfURL:[NSURL URLWithString:friend.photourl]];
        friend.fbid = [friendInfo objectForKey:@"fbid"];
             NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    else
    {
        friend = [matches lastObject];
    }

    return friend;
}



+(void)removeFriendWithid:(NSString *)fbid inManagedObjectContext:(NSManagedObjectContext *)context
{
    Friend *friend = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    request.predicate = [NSPredicate predicateWithFormat:@"(fbid = %@)",fbid];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"fullname" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if(!matches)
    {
        //handle error..matches query shouldnot return nil
        NSLog(@"Query error");
    }
    else if ([matches count]>1)
    {
        //handle error..matches count cant be greater than 1..that means more than 1 unique friend exits in db
        NSLog(@"MAtches > 1");
    }
    else if ([matches count] == 0)
    {
        
    }
    else
    {
        friend = [matches lastObject];
        [context deleteObject:friend];
        
    }
    
    NSError *saveError = nil;
    [context save:&saveError];
    
}

+(void)refreshFriendDatabase:(NSManagedObjectContext *)context
{
    //checking if that same photo already exists in database (by quering db)
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"daysleft" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    for (int i =0 ; i<[matches count]; i++)
    {
        Friend *friend = (Friend *)[matches objectAtIndex:i];
    
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friend.birthdate];
        int currentYear = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]] year];
        
        NSString *tempstr;
        if ([components month]<10)
        {
        tempstr =   [NSString stringWithFormat:@"0%d/%d/%d",[components month],[components day],currentYear];
        }
        else
        {
            tempstr =   [NSString stringWithFormat:@"%d/%d/%d",[components month],[components day],currentYear];
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

       
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        [NSTimeZone resetSystemTimeZone];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
       NSDate *upcomingBirthdate = [dateFormatter dateFromString:tempstr];
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init] ;
        [componentsToSubtract setDay:-1];
        NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0];
        
            //if upcoming date calculated has already passed put next year date as upcoming
        if ([upcomingBirthdate compare:yesterday] == NSOrderedAscending)
        {
            if ([components month]<10)
            {
            tempstr =   [NSString stringWithFormat:@"0%d/%d/%d",[components month],[components day],currentYear+1];
            }
            else
            {
                 tempstr =   [NSString stringWithFormat:@"%d/%d/%d",[components month],[components day],currentYear+1];
                
            }
            
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [NSTimeZone resetSystemTimeZone];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            upcomingBirthdate = [dateFormatter dateFromString:tempstr];
        }
        
        //calculate age
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friend.birthdate];
        int buddayyear = [components year];
        int buddaymonth =[components month];
        int buddaydate = [components day];
        
        
        //special case budday on 28th feb
        if (buddaydate == 28 && buddaymonth == 2)
        {
            tempstr =   [NSString stringWithFormat:@"0%d/%d/%d",[components month],[components day],currentYear+4];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [NSTimeZone resetSystemTimeZone];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            upcomingBirthdate = [dateFormatter dateFromString:tempstr];
            
        }
        
        components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:upcomingBirthdate];
        int thisbuddayyear = [components year];
       int friendsage = thisbuddayyear - buddayyear;
        
        
        //Calculating Days Left
        
        NSDate *fromDate;
        NSDate *toDate;
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                     interval:NULL forDate:[NSDate date]];
        [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                     interval:NULL forDate:upcomingBirthdate];
        
        NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                                   fromDate:fromDate toDate:toDate options:0];
        
        int temp = [difference day];

        
        friend.upcomingbirthdate = upcomingBirthdate;
        friend.age = [NSNumber numberWithInt:friendsage];
        friend.daysleft = [NSNumber numberWithInt:temp];
        

    }
    
    NSError *saveError = nil;
    [context save:&saveError];
}

@end
