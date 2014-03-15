//
//  ViewController.m
//  BuddayReminder
//
//  Created by Ankit on 17/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "CustomCells/FriendTableViewCustomCell.h"
#import "../Friend+Create.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPerson.h>
#import "Contact+Create.h"
#import "SettingsViewController.h"
#import "AddBirthdayViewController.h"
#import "InternetCheck.h"


@interface ViewController ()
{
    
    NSMutableDictionary *friendinfo;
    NSMutableDictionary *contactinfo;
    NSDateFormatter *dateFormatter;
    BOOL searchMode;
    ABAddressBookRef addressBook;
    NSCalendar *gregorianCalendar;
    
    
    UIRefreshControl *refreshControl;
    UIActivityIndicatorView *indicatorView;
    BOOL shouldRefresh;

    
    //
    NSDate *upcomingBirthdate;
    NSDate *birthdate ;
    int friendsage;
    int temp;

    AddBirthdayViewController *abvc;

    SettingsViewController *svc;

}

@end

@implementation ViewController
@synthesize UpcomingBirthdaysTableView =_UpcomingBirthdaysTableView;
@synthesize fetchedObjects = _fetchedObjects;
@synthesize friendsDatabase = _friendsDatabase;
@synthesize localNotifObjectsArray = _localNotifObjectsArray;
@synthesize birthdate = _birthdate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    [InternetCheck sharedInstance];
    dateFormatter = [[NSDateFormatter alloc] init];
    
    // Do any additional setup after loading the view, typically from a nib.
    friendinfo = [[NSMutableDictionary alloc]init];
    contactinfo =[[NSMutableDictionary alloc]init];
    gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Adding Self as an observer to FB sessionstatechange
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:)  name:BRSessionStateChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timechange) name:UIApplicationSignificantTimeChangeNotification object:nil];

    
    [fbButton setSelected:YES];
  
    //set view mode to fb
    self.viewMode = FacebookMode;
    
    actionButtonsBgView.layer.borderColor = [UIColor blackColor].CGColor;
    actionButtonsBgView.layer.borderWidth = 1.0f;
    actionButtonsBgView.layer.cornerRadius = 3.0f;
    
    
    cellMagnifiedView.layer.borderColor = [UIColor blackColor].CGColor;
    cellMagnifiedView.layer.borderWidth = 1.0f;
    cellMagnifiedView.layer.cornerRadius = 5.0f;
    [self.view addSubview:cellMagnifiedView];
    [cellMagnifiedView setHidden:YES];
   // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //default settings
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"areNotificationsEnabled"];
    [[NSUserDefaults standardUserDefaults]setObject:@"On Birthday" forKey:@"Reminders"];
    [[NSUserDefaults standardUserDefaults]setObject:@"00:00 AM" forKey:@"Daily Notify Time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    shouldRefresh=YES;
    [self topPullToRefresh];

}


-(void) topPullToRefresh
{
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.UpcomingBirthdaysTableView addSubview:refreshControl];
    
}

-(void)refreshView:(UIRefreshControl *)refresh
{
    [refreshControl beginRefreshing];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing Data..."];
    [self performSelector:@selector(endLoader:) withObject:refresh afterDelay:1.0f];
    
}

-(void) endLoader:(UIRefreshControl *)loader
{
//    [self setupFetchedResultsController];
    [self timechange];
    [loader endRefreshing];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    
    //
    [bannerView setBackgroundColor:[UIColor clearColor]];
     [bannerView setDelegate:self];
    //
    if (![InternetCheck sharedInstance].internetWorking)

    {
        [bannerView setHidden:YES];
        [bannerView setDelegate:nil];
        self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320,[[UIScreen mainScreen] bounds].size.height-160);
        NSLog(@"bounds height %f",[[UIScreen mainScreen] bounds].size.height-160);

    }
    else
    {
        //check for receipt
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [bannerView setHidden:YES];
            self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320,[[UIScreen mainScreen] bounds].size.height-160);
            [bannerView setDelegate:nil];
            
            NSLog(@"bounds height %f",[[UIScreen mainScreen] bounds].size.height-160);
            
            
        }
        else
        {
            [[RevMobAds session] showFullscreen];
            [bannerView setHidden:NO];
            self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320,[[UIScreen mainScreen] bounds].size.height-160-50);
            [bannerView setDelegate:self];

            
        }

    }
    
    
    
     abvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddBirthdayViewController"];
    svc = [ self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    //set Friends Database
    if(!self.friendsDatabase)
    {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url =[url URLByAppendingPathComponent:@"Default Friends Database"];
        self.friendsDatabase = [[ UIManagedDocument alloc] initWithFileURL:url];
    }
    if (FBSession.activeSession.isOpen)
    {
        [self populateUserDetails];
        [self useDocument];

    }
    
}


-(void)setfriendsDatabase:(UIManagedDocument *)friendsDatabase
{
    if(_friendsDatabase != friendsDatabase)
    {
        _friendsDatabase = friendsDatabase;
        [self useDocument];
    }
}


//database check
-(void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.friendsDatabase.fileURL path]]) {
        [self.friendsDatabase saveToURL:self.friendsDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             [self populateFriendDetailsintoDB:self.friendsDatabase];
        }];
        
    }
    else if(self.friendsDatabase.documentState == UIDocumentStateClosed)
    {
        [self.friendsDatabase openWithCompletionHandler:^(BOOL success){
            [self setupFetchedResultsController];
        }];
    }
    else if(self.friendsDatabase.documentState == UIDocumentStateNormal)
    {
        [self setupFetchedResultsController];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"viewcontroller memorywarning");
}


- (void)viewDidUnload {
    
    friendinfo = nil;
    contactinfo = nil;

    [self setUpcomingBirthdaysTableView:nil];
    [self setMyUsername:nil];
    [self setMyProfilePic:nil];
    [self setPopulatingDataActivityIndicator:nil];
    [super viewDidUnload];
}

-(void)dealloc
{
    //Removing self as an observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    friendinfo = nil;
    contactinfo = nil;

}


#pragma mark- methods handling fb stuff

-(void)logoutButtonWasPressed:(id)sender
{
    //Clear token info
    [FBSession.activeSession closeAndClearTokenInformation];
    searchMode = NO;
}


- (void)sessionStateChanged:(NSNotification*)notification {
    [self populateUserDetails];
}
#pragma end

- (void)populateUserDetails
{
    
    if (FBSession.activeSession.isOpen)
    {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,NSDictionary<FBGraphUser> *user,NSError *error) {
             if (!error)
             {
                 self.myUsername.text = user.name;
                 self.myProfilePic.profileID = user.id;
             }
         }];
        
    }
}


-(void)populateFriendDetailsintoDB:(UIManagedDocument *)document
{
    [self.populatingDataActivityIndicator startAnimating];
    populatingLabel.hidden = NO;
    if (FBSession.activeSession.isOpen)
    {
        
        [FBRequestConnection startWithGraphPath:@"me/friends?fields=first_name,last_name,birthday,picture.type(normal)"
                        completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         if (!error)
         {
             if (result[@"data"] && [result[@"data"] count] > 0)
             {
                 [fbButton setEnabled:NO];
                 [contactsButton setEnabled:NO];
                 [settingsButton setEnabled:NO];
                 [addButton setEnabled:NO];
        
                 //bground thread
                 dispatch_queue_t popQueue = dispatch_queue_create("com.entropyUnlimited.myQueue", NULL);
                 dispatch_async(popQueue, ^{
                    
                 NSArray *resultArray =  [result objectForKey:@"data"];
                 for (int i=0; i<[resultArray count]; i++)
                 {
                     [friendinfo removeAllObjects];
                     NSDictionary *dictionary = [resultArray objectAtIndex:i];
                     NSString *first_name = [dictionary objectForKey:@"first_name"];
                     NSString *last_name = [dictionary objectForKey:@"last_name"];
                     //Get Date From Data
                     NSString *birthday = [dictionary objectForKey:@"birthday"];
                     
                     if ([first_name isEqualToString:@"Aditya"])
                     {
                         NSLog(@"first name %@ \n Birthday  %@",first_name,birthday);

                     }
                     
                     // ...using a date format corresponding to your date
                     [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                     [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                     [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                     [NSTimeZone resetSystemTimeZone];
                     [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                     
                     // Parse the string representation of the date
                    // NSDate *birthdate = [[NSDate alloc]init];
                     [dateFormatter setDateFormat:@"MM/dd/yyyy"];

                     birthdate =[dateFormatter dateFromString:birthday];
                     
                    if (!birthdate && birthday)
                     {
                         NSLog(@"birthday : %@",birthday);
                         birthday = [NSString stringWithFormat:@"%@/1200",birthday];
                         NSLog(@"birthday : %@",birthday);
                         [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                        birthdate = [dateFormatter dateFromString:birthday];
                         
                         
                         NSLog(@"birtjdate : %@",birthdate);
                     }

                     NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:birthdate];
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
                     
                     [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                     [dateFormatter setDateStyle:NSDateFormatterShortStyle];
                     [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                     [NSTimeZone resetSystemTimeZone];
                     [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                    
                   //  NSDate *upcomingBirthdate = [[NSDate alloc]init];
                    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
                     upcomingBirthdate = [dateFormatter dateFromString:tempstr];
                     
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
                    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:birthdate];
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
                      friendsage = thisbuddayyear - buddayyear;

                     
                     //Calculating Days Left

                     temp = [self daysBetweenDate:[NSDate date] andDate:upcomingBirthdate];
                        NSLog(@"days left : %d",temp);
                     
                     //getting photourl
                     NSString *url = [[[dictionary objectForKey:@"picture"] objectForKey:@"data"]objectForKey:@"url"];
                     
                     //getting fb id of friend
                     NSString *fbid = [dictionary objectForKey:@"id"];
                     //Adding To dictionary
                     if (birthday)
                     {
                         [friendinfo setObject:[NSString stringWithFormat:@"%@ %@",first_name,last_name] forKey:@"fullname"];
                         [friendinfo setObject:birthdate forKey:@"birthdate"];
                         [friendinfo setObject:upcomingBirthdate forKey:@"upcomingbirthdate"];
                         [friendinfo setObject:url forKey:@"photourl"];
                         [friendinfo setObject:[NSNumber numberWithInt:friendsage] forKey:@"age"];
                         [friendinfo setObject:[NSNumber numberWithInt:temp] forKey:@"daysleft"];
                         [friendinfo setObject:fbid forKey:@"fbid"];
                         
                         dispatch_sync(dispatch_get_main_queue(), ^{
                         [Friend friendWithInfo:friendinfo inManagedObjectContext:document.managedObjectContext];
                             
                         });

                     }
                      }
                     [self firstTimeSync:self.friendsDatabase];
                 });
                 
             }
         }
     }];
    }
}





#pragma mark-get data from address book
-(void)firstTimeSync:(UIManagedDocument *)document
{

    addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        // Semaphore is used for blocking until response
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
       // dispatch_release(sema);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
        [self getPersonOutOfAddressBook:document];
        
    }
    if (accessGranted) {
        [self getPersonOutOfAddressBook:document];
        
    }
}


- (void)getPersonOutOfAddressBook:(UIManagedDocument *)document
{
    
    if (addressBook != nil)
    {
        NSLog(@"Succesful.");
        NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSLog(@"all contacts count %d",[allContacts count]);
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            
            NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName =  (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            
            NSDate *birthday = (__bridge_transfer NSDate*)ABRecordCopyValue(contactPerson, kABPersonBirthdayProperty);
    
            
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:birthday];
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
        
            
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [NSTimeZone resetSystemTimeZone];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            
            //calculating  upcoming budday
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];

          upcomingBirthdate = [dateFormatter dateFromString:tempstr];
            NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init] ;
            [componentsToSubtract setDay:-1];
            NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0];
            
            if ([upcomingBirthdate compare:yesterday] == NSOrderedAscending)
            {
                if ([components month]<10) {
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
            components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:birthday];
            int buddayyear = [components year];
            int buddaymonth =[components month];
            int buddaydate = [components day];
            components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:upcomingBirthdate];
            int thisbuddayyear = [components year];
             friendsage = thisbuddayyear - buddayyear;
            
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
            
            
            //Calculating Days Left
            
            int daysleft = [self daysBetweenDate:[NSDate date] andDate:upcomingBirthdate];
            
            //extracting image data
            NSData *imagedata = nil;
             imagedata = (__bridge_transfer NSData*)ABPersonCopyImageData(contactPerson);
            
            ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
            NSUInteger j = 0;
            NSString *personalEmail=nil;
            NSString *workEmail=nil;
            for (j = 0; j < ABMultiValueGetCount(emails); j++)
            {
                NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
                
                if (j == 0)
                {
                    personalEmail = [NSString stringWithString:email];
                }
                
                else if (j==1)
                {
                    workEmail = [NSString stringWithString:email];
                }
                CFRelease(emails);
                
            }
            
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(contactPerson,kABPersonPhoneProperty);
            NSString *phone = nil;
            if (ABMultiValueGetCount(phoneNumbers) > 0)
            {
                phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                
            }
            else {
                phone = @"[None]";
            }
            CFRelease(phoneNumbers);
            
            //Adding To dictionary
            if (birthday) {
                [contactinfo removeAllObjects];

                
                [contactinfo setObject:[NSString stringWithFormat:@"%@",fullName] forKey:@"fullname"];
                if (personalEmail) {
                    [contactinfo setObject:personalEmail forKey:@"emailid"];
                }
                else if(workEmail)
                    [contactinfo setObject:workEmail forKey:@"emailid"];

                if (birthday)
                {
                    [contactinfo setObject:birthday forKey:@"birthdate"];
                    [contactinfo setObject:upcomingBirthdate forKey:@"upcomingbirthdate"];
                    [contactinfo setObject:[NSNumber numberWithInt:friendsage] forKey:@"age"];
                    [contactinfo setObject:[NSNumber numberWithInt:daysleft] forKey:@"daysleft"];
                    if (imagedata)
                    {
                        [contactinfo setObject:imagedata forKey:@"photodata"];
                    }
                    [contactinfo setObject:phone forKey:@"phoneno"];
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                    [Contact contactWithInfo:contactinfo inManagedObjectContext:document.managedObjectContext];
                    });
                }

            }
        }
        
        [self setupFetchedResultsController];

    }
    else
    {
        NSLog(@"Error reading Address Book");
    }
}


//Fetch Data from coredata
-(void)setupFetchedResultsController
{
    //After the db has been populated
    //self.fetchedResultsController = . ... . ..
    NSFetchRequest *request;
    if (self.viewMode == FacebookMode)
       request = [ NSFetchRequest fetchRequestWithEntityName:@"Friend"];
    else
       request = [ NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"daysleft" ascending:YES ]];
    NSError *error = nil;
    
    if (searchMode) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(fullname CONTAINS[c] %@)",searchbar1.text];
        [request setPredicate:predicate];
    }
    else
    {
        [request setPredicate:nil];
    }
    fetchedObjects = [self.friendsDatabase.managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"fetched count %d",[fetchedObjects count]);
   
   dispatch_async(dispatch_get_main_queue(), ^{
    [fbButton setEnabled:YES];
    [contactsButton setEnabled:YES];
    [settingsButton setEnabled:YES];
    [addButton setEnabled:YES];
    [self.UpcomingBirthdaysTableView reloadData];
    [self.populatingDataActivityIndicator stopAnimating];
    [populatingLabel setHidden:YES];

    });
    [self setupLocalNotifications];

}





#pragma mark - TableView DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"FriendTableViewCustomCell";
    FriendTableViewCustomCell *cell = (FriendTableViewCustomCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
      cell =[[FriendTableViewCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  
    }
    if (self.viewMode == FacebookMode)
    {
        Friend * friend =[fetchedObjects objectAtIndex:indexPath.row];
        cell.friendName.text = [NSString stringWithFormat:@"%@",friend.fullname];
        
        if (friend.photoData)
        {
            [cell.friendsPhotu setImage:[UIImage imageWithData:friend.photoData]];
        }
        else
        {
            [cell.friendsPhotu setImage:nil];
        }
        
        
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friend.birthdate];
        if ([components year] == 1200)
        {
            NSString *str = [dateFormatter stringFromDate:friend.birthdate];
            str = [str stringByReplacingOccurrencesOfString:@"1200" withString:@"????"];
            cell.bDate.text = str;
            cell.friendAge.text = @"????";
        }
        else
        {
            cell.bDate.text = [dateFormatter stringFromDate:friend.birthdate];
            cell.friendAge.text = [NSString stringWithFormat:@"%@",friend.age];
        }
        if ([friend.daysleft intValue] == 0)
        {
            cell.inLabel.text = [NSString stringWithFormat:@"today"];
            [cell.daysLeft setHidden:YES];
        }
        else if([friend.daysleft intValue] == 1)
        {
            cell.inLabel.text = [NSString stringWithFormat:@"tommorow"];
            [cell.daysLeft setHidden:YES];
        }
        else
        {
            [cell.daysLeft setHidden:NO];
            cell.inLabel.text = @"in";
            cell.daysLeft.text = [NSString stringWithFormat:@"%@ days",friend.daysleft];
        }

    }
    else
    {
        Contact * friend =[fetchedObjects objectAtIndex:indexPath.row];
        cell.friendName.text = [NSString stringWithFormat:@"%@",friend.fullname];
        
        if (friend.photoData)
        {
            [cell.friendsPhotu setImage:[UIImage imageWithData:friend.photoData]];
        }
        else
        {
            [cell.friendsPhotu setImage:nil];
        }
        
        
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friend.birthdate];
        if ([components year] == 1604)
        {
            NSString *str = [dateFormatter stringFromDate:friend.birthdate];
            str = [str stringByReplacingOccurrencesOfString:@"1604" withString:@"????"];
            cell.bDate.text = str;
            cell.friendAge.text = @"????";
        }
        else
        {
            cell.bDate.text = [dateFormatter stringFromDate:friend.birthdate];
            cell.friendAge.text = [NSString stringWithFormat:@"%@",friend.age];
        }
        if ([friend.daysleft intValue] == 0)
        {
            cell.inLabel.text = [NSString stringWithFormat:@"today"];
            [cell.daysLeft setHidden:YES];
        }
        else if([friend.daysleft intValue] == 1)
        {
            cell.inLabel.text = [NSString stringWithFormat:@"tommorow"];
            [cell.daysLeft setHidden:YES];
        }
        else
        {
            [cell.daysLeft setHidden:NO];
            cell.inLabel.text = @"in";
            cell.daysLeft.text = [NSString stringWithFormat:@"%@ days",friend.daysleft];
        }
   
    }
    
   return cell;
}


#pragma mark - TableView Delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.UpcomingBirthdaysTableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.viewMode == FacebookMode)
    {
        Friend *friend =[fetchedObjects objectAtIndex:indexPath.row];
        
        self.friendname = [NSString stringWithFormat:@"%@",friend.fullname];
        self.profilepicdata = [NSData dataWithData:friend.photoData];
        self.userfbid = friend.fbid;
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friend.birthdate];
        if ([components year] == 1200)
        {
            NSString *str = [dateFormatter stringFromDate:friend.birthdate];
            str = [str stringByReplacingOccurrencesOfString:@"1200" withString:@"????"];
            self.birthdate = str;
            self.friendsAgeString = @"????";
        }

        else
        {
            self.birthdate =[dateFormatter stringFromDate:friend.birthdate];
            self.friendsAgeString = [NSString stringWithFormat:@"%d",[friend.age intValue]];
        }
        self.daysLeftToBday = [NSString stringWithFormat:@"%d days",[friend.daysleft intValue]];
        self.phoneNumber = @"";
        self.emailId = @"";
    }
    
    else
    {
        
        Contact *contact = [fetchedObjects objectAtIndex:indexPath.row];
        self.friendname = [NSString stringWithFormat:@"%@",contact.fullname];
        self.profilepicdata = [NSData dataWithData:contact.photoData];
        self.userfbid = @"-1";
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        self.birthdate =[dateFormatter stringFromDate:contact.birthdate];
        self.friendsAgeString = [NSString stringWithFormat:@"%d",[contact.age intValue]];
        self.daysLeftToBday = [NSString stringWithFormat:@"%d days",[contact.daysleft intValue]];
        self.phoneNumber = contact.phoneno;
        self.emailId = contact.emailid;
    }
    name.text = [NSString stringWithString:self.friendname];
    profilepic.image = [UIImage imageWithData:self.profilepicdata];
    bdate.text = [NSString stringWithString:self.birthdate];
    age.text = [NSString stringWithString:self.friendsAgeString];
    if ([self.daysLeftToBday intValue] == 0)
    {
        [daysLeft setHidden:YES];
        inLabel.text = [NSString stringWithFormat:@"today"];
    }
    else if ([self.daysLeftToBday intValue] == 1)
    {
        [daysLeft setHidden:YES];
        inLabel.text = [NSString stringWithFormat:@"tommorow"];
    }
    else
    {
        [daysLeft setHidden:NO];
        inLabel.text = [NSString stringWithFormat:@"in"];
        daysLeft.text = [NSString stringWithString:self.daysLeftToBday];
    }
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    cellRect = CGRectOffset(cellRect, -tableView.contentOffset.x, -tableView.contentOffset.y);
   
    cellMagnifiedView.frame = CGRectMake(cellRect.origin.x,cellRect.origin.y+160,320,cellRect.size.height);
    [cellMagnifiedView setAlpha:0];
    [actionButtonsBgView setHidden:YES];
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                                    [overlayView setBackgroundColor:[UIColor whiteColor]];
                                    [overlayView setHidden:NO];
                                    [cellMagnifiedView setHidden:NO];
                                    cellMagnifiedView.frame = CGRectMake(cellRect.origin.x, cellRect.origin.y+160-50, 320, 180);
                                        [cellMagnifiedView setAlpha:1.0];
                         
    }completion:^(BOOL finished)
     {
         if(finished)
         {
             [actionButtonsBgView setHidden:NO];
         }
    }];
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.UpcomingBirthdaysTableView setEditing:editing animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

        return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    FriendTableViewCustomCell * cell = (FriendTableViewCustomCell *)[self.UpcomingBirthdaysTableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        //remove from modal and
        if (self.viewMode == contactMode)
        {
            [Contact removeContactWithName:cell.friendName.text inManagedObjectContext:self.friendsDatabase.managedObjectContext];

        }
        else
        {
            Friend *friend =[fetchedObjects objectAtIndex:indexPath.row];
            
            [Friend removeFriendWithid:friend.fbid inManagedObjectContext:self.friendsDatabase.managedObjectContext];

        }
        
        NSMutableArray * fetchedObjectsMutable =[fetchedObjects mutableCopy];
        [fetchedObjectsMutable removeObjectAtIndex:indexPath.row];
        fetchedObjects = [NSArray arrayWithArray:fetchedObjectsMutable];
        
        // then delete from table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0;
}
#pragma mark- SearchBarDelegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar1
{
    if ([InternetCheck sharedInstance].internetWorking)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
        [[RevMobAds session]hideBanner];
        }
    }
    searchbar1.showsCancelButton = YES;
    searchMode =YES;
    return YES;
}



- (void)searchBar:(UISearchBar *)searchBar1 textDidChange:(NSString *)searchText
{
 
    if([searchText isEqualToString:@""])
        searchMode=NO;
    else
        searchMode=YES;
    if (searchMode)
    {
        [self setupFetchedResultsController];
    }
    
    
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1
{
    searchbar1.showsCancelButton=NO;
    [searchbar1 resignFirstResponder];
    [searchbar1 setText:@""];
    [searchbar1 setPlaceholder:@"Search"];
    searchMode = NO;
    if ([InternetCheck sharedInstance].internetWorking)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]showBanner];
        }
    }    [self setupFetchedResultsController];
}

// called when Search (in our case “Done”) button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1
{
    
    searchbar1.showsCancelButton=NO;
    [searchbar1 resignFirstResponder];
    searchMode = NO;
}



#pragma mark - MFmailcomposer delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        NSLog(@"It's away");
    }
    else if (result == MFMailComposeResultCancelled)
    {
        NSLog(@"Mail cancelled");
    }
    else if (result == MFMailComposeResultSaved)
    {
        NSLog(@"Mail saved");
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Something Went Wrong!!"
                                    message:@"Message sending failed."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
        
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]showBanner];
        }
    }];
}


#pragma mark - MFmessagecomposer delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]showBanner];
        }
    }];
}


#pragma mark - Buttons tapped
- (IBAction)FbButtonBapped:(UIButton *)sender {
    
//    [friendsbgView setBackgroundColor:[UIColor colorWithRed:239 green:239 blue:244 alpha:1]];
//    [contactsBgView setBackgroundColor:[UIColor whiteColor]];
    [fbButton setSelected:YES];
    [contactsButton setSelected:NO];
    self.viewMode = FacebookMode;
    [self setupFetchedResultsController];

  }

- (IBAction)contactsButtonTapped:(UIButton *)sender {
//    [friendsbgView setBackgroundColor:[UIColor whiteColor]];
//    [contactsBgView setBackgroundColor:[UIColor colorWithRed:239/255 green:239/255 blue:244/255 alpha:1]];
    [contactsButton setSelected:YES];
    [fbButton setSelected:NO];
    self.viewMode = contactMode;
    [self setupFetchedResultsController];

}

- (IBAction)logoutTapped:(UIButton *)sender {
    [self logoutButtonWasPressed:sender];
}

- (IBAction)addEventTapped:(UIButton *)sender {
   
    abvc.navigationController.title = @"Add Birthday";
    abvc.delegate = self;
    [self.navigationController pushViewController:abvc animated:YES];

}

- (IBAction)smsButtonClicked:(UIButton *)sender
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error!!" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    if (![self.phoneNumber isEqualToString:@""])
    {
        [self sendSms:[NSArray arrayWithObject:self.phoneNumber]];
        
    }
    else
    {
        [[[UIAlertView alloc]initWithTitle:@"Error!!" message:@"SMS couldnot be sent.No phone number found." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
    }
    
}

- (IBAction)emailButtonClicked:(UIButton *)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        if (self.emailId)
        {
            [self sendEmail:self.emailId];
        }
        else
            [[[UIAlertView alloc] initWithTitle:@"Error!!"
                                        message:@"No Email Id exists for this contact"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]
             show];

        
    } else {
        // Handle the error
        [[[UIAlertView alloc] initWithTitle:@"Error!!"
                                    message:@"Sorry.Your Device isn't configured for mail."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
        
    }
}

- (IBAction)callButtonClicked:(UIButton *)sender
{
        [self callNumber:self.phoneNumber];
}


- (IBAction)settingsButtonTapped:(UIButton *)sender {
    
    svc.title = @"Settings";
    svc.delegate = self;
    [self.navigationController pushViewController:svc animated:YES];
}

- (IBAction)backToFrndsList:(UIButton *)sender
{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cellMagnifiedView.frame = CGRectMake(0, cellMagnifiedView.frame.origin.y+50, 320,80);
        cellMagnifiedView.alpha = 0.0;
        [overlayView setBackgroundColor:[UIColor clearColor]];
        [actionButtonsBgView setHidden:YES];

    }completion:^(BOOL finished){
        
           [cellMagnifiedView setHidden:YES];
           [overlayView setHidden:YES];
    }];
   
}

#pragma mark- FB publish story using graph api Action methods


- (IBAction)postOnWallClicked:(UIButton *)sender
{
    if ([self.userfbid intValue]!=-1)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
        [[RevMobAds session]hideBanner];
        }
        NSLog(@"Fb User ID : %@",self.userfbid);
        // Put together the dialog parameters
        NSMutableDictionary *params =[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      @"Who's Birthday Is It?", @"name",
                                      @"Best Wishes on your B'day.", @"caption",
                                      @"Who's Birthday Is It? is the cool new app for your iphone that  will keep track of your important dates for you,be it Birthdays or anniversaries.Also with buddy reminder,you can easily send out your wishes to a friend via Facebook,email,Sms or just simply call them..everything from one app.", @"description",
                                      @"https://www.facebook.com/pages/Whos-Birthday-Is-It/612710648777385", @"link",
                                      @"http://i.imgur.com/kwrVgky.png" ,@"picture",
                                      self.userfbid,@"to",
                                      nil];
        
        // Invoke the dialog
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error)
             {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             }
             else {
                 if (result == FBWebDialogResultDialogNotCompleted)
                 {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 }
                 else
                 {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"])
                     {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                        

                     }
                     else
                     {
                         // User clicked the Share button
                         NSString *msg = [NSString stringWithFormat:
                                          @"Posted story on %@ wall",
                                          self.friendname];
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Result"
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil]
                          show];
                     }
                 }
             }
             if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
             {
                 [[RevMobAds session]showBanner];
             }
         }];
        
        
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!!"
                                    message:@"No facebook Id exists for this contact"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil]
         show];
    }
    
}


#pragma mark -helper methods
- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

#pragma mark - Helper methods
/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(void)sendSms:(NSArray *)numbersArray
{
    // NSArray *recipents = @[@"7838557292"];
    NSString *message = [NSString stringWithFormat:@"Heyy!!!Happy Birthday %@ !!",self.friendname];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:numbersArray];
    [messageController setBody:message];
    messageController.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]hideBanner];
        }
        
    }];
}

-(void) callNumber:(NSString *)number
{
    if (![number isEqualToString:@""]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",number]]])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",number]]];
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Call couldnot be made.No number found." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            
        }
    }
    else
    {
         [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Call couldnot be made.No number found." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
   }

-(void)sendEmail:(NSString *)emailId
{
    // Show the composer
 
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:[NSArray arrayWithObject:emailId]];
    [controller setSubject:@"Heyy!!!"];
    [controller setMessageBody:[NSString stringWithFormat:@"Happy Birthday %@ !!",self.friendname] isHTML:NO];
    if (controller)
   //     [self presentModalViewController:controller animated:YES];
    [self presentViewController:controller animated:YES completion:^{
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receipt"])
        {
            [[RevMobAds session]hideBanner];
        }
    }];
 
}


#pragma mark - Settings Action Delegate Methods
-(void)refreshButtonTapped
{
    if ([InternetCheck sharedInstance].internetWorking)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!!" message:@"Birthday Reminder Plus will now refresh all data i.e refetch all data from your facebook account. (Requires Internet Connection)." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Ok",nil];
             [alert show];
        
      
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection!!" message:@"Please check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }


}
-(void)logoutTapped
{
    [self logoutButtonWasPressed:nil];
}

-(void)settingsApplied
{
    [self setupLocalNotifications];
}

#pragma mark - AdBirthdayDelegateMethods

-(void)addBirthdaywithfriendsName:(NSString *)friendname andEmail:(NSString *)email andphonenumber:(NSString *)phoneNumber andImageData:(NSData *)imageData andBirthdate:(NSDate *)friendsbirthdate
{
    
    //
    self.viewMode = contactMode;
    [[[UIAlertView alloc]initWithTitle:@"Added!!" message:@"Birthday added to contacts tab" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friendsbirthdate];
    int currentYear = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]] year];
  
    NSString *tempstr;
    if ([components month]<10)
    {
        tempstr = [NSString stringWithFormat:@"0%d/%d/%d",[components month],[components day],currentYear];
    }
    else
    {
        tempstr = [NSString stringWithFormat:@"%d/%d/%d",[components month],[components day],currentYear];
    }
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [NSTimeZone resetSystemTimeZone];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
   upcomingBirthdate = [dateFormatter dateFromString:tempstr];
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init] ;
    [componentsToSubtract setDay:-1];
    NSDate *yesterday = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0];
    
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
    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:friendsbirthdate];
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
    friendsage = thisbuddayyear - buddayyear;
    
    
    //Calculating Days Left
    
    temp = [self daysBetweenDate:[NSDate date] andDate:upcomingBirthdate];
    NSLog(@"days left : %d",temp);
    
    //Adding To dictionary
    [contactinfo removeAllObjects];
    [contactinfo setObject:friendname forKey:@"fullname"];
    [contactinfo setObject:email forKey:@"emailid"];
    [contactinfo setObject:friendsbirthdate forKey:@"birthdate"];
    [contactinfo setObject:upcomingBirthdate forKey:@"upcomingbirthdate"];
    [contactinfo setObject:[NSNumber numberWithInt:friendsage] forKey:@"age"];
    [contactinfo setObject:[NSNumber numberWithInt:temp] forKey:@"daysleft"];
    if (imageData)
    {
            [contactinfo setObject:imageData forKey:@"photodata"];
    }
    [contactinfo setObject:phoneNumber forKey:@"phoneno"];
        [Contact contactWithInfo:contactinfo inManagedObjectContext:self.friendsDatabase.managedObjectContext];
    [self setupFetchedResultsController];
    self.viewMode = contactMode;

}


//setup local notifications
-(void)setupLocalNotifications
{
       //check if notifications are on
   BOOL isOn = [[NSUserDefaults standardUserDefaults]boolForKey:@"areNotificationsEnabled"];
    if (isOn)
    {
        [[UIApplication sharedApplication]cancelAllLocalNotifications];
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init] ;
        NSString * reminderWhen =[[NSUserDefaults standardUserDefaults]objectForKey:@"Reminders"];
        NSString *reminderTime = [[NSUserDefaults standardUserDefaults]objectForKey:@"Daily Notify Time"];
        NSLog(@"Reminder wen :%@ %@",reminderWhen,reminderTime);
        
        //divide remindertime
        [dateFormatter setDateFormat:@"HH:mm a"];
       NSDate *firetime = [dateFormatter dateFromString:reminderTime];
        NSDateComponents *components = [gregorianCalendar components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:firetime];
        int fhour = [components hour];
        int fmin = [components minute];
        NSFetchRequest *request;
        int count =0;
        while (count <=1)
        {
            if (count == 0)
            {
                //fetchobjects- only for fb friends(abhi k liye)
                request = [ NSFetchRequest fetchRequestWithEntityName:@"Friend"];
            }
            else
            {
                //fetchobjects- only for fb friends(abhi k liye)
                request = [ NSFetchRequest fetchRequestWithEntityName:@"Contact"];
            }
            count = count + 1;
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"daysleft" ascending:YES ]];
        NSError *error = nil;
        NSPredicate *predicate;
        NSDate *fdate;
        
        //create NSDate object with settings wala date nd tym
        if ([reminderWhen isEqualToString:@"On Birthday"])
        {
            predicate = [NSPredicate predicateWithFormat:@"daysleft = 1"];
        }
        else if ([reminderWhen isEqualToString:@"1 day before birthday"])
        {
             predicate = [NSPredicate predicateWithFormat:@"daysleft = 2"];
        }
        else if ([reminderWhen isEqualToString:@"3 days before birthday"])
        {
            predicate = [NSPredicate predicateWithFormat:@"daysleft = 4"];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"daysleft = 8"];
        }
       
        [request setPredicate:predicate];
        localNotifObjectsArray = [self.friendsDatabase.managedObjectContext executeFetchRequest:request error:&error];
        NSLog(@"fetched count %d",[localNotifObjectsArray count]);
        
       
       //Create the localNotification object and scheduling local notifs
        NSString *alertBody;
        for (int i =0; i< [localNotifObjectsArray count]; i++)
        {
             UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            
            id obj = [ localNotifObjectsArray objectAtIndex:i];
            if ([obj isKindOfClass:[Friend class]])
            {
                Friend * friend = (Friend *)obj;
                NSLog(@"Friendname : %@",friend.fullname );
                
                if ([friend.daysleft intValue]-1 == 0)
                {
                      alertBody =[ NSString stringWithFormat:@"Its %@'s birthday today",friend.fullname];
                }
                else if ([friend.daysleft intValue]-1 == 1)
                {
                    alertBody =[ NSString stringWithFormat:@"Its %@'s birthday tommorow",friend.fullname];
   
                }
                else
                {
                alertBody =[ NSString stringWithFormat:@"Its %@'s birthday in %d days",friend.fullname,[friend.daysleft intValue]-1];
                }
            }
            else
            {
                    Contact * contact = (Contact *)obj;
                    NSLog(@"Friendname : %@",contact.fullname );
                    
                    if ([contact.daysleft intValue]-1 == 0)
                    {
                        alertBody =[ NSString stringWithFormat:@"Its %@'s birthday today",contact.fullname];
                    }
                    else if ([contact.daysleft intValue]-1 == 1)
                    {
                        alertBody =[ NSString stringWithFormat:@"Its %@'s birthday tommorow",contact.fullname];
                        
                    }
                    else
                    {
                        alertBody =[ NSString stringWithFormat:@"Its %@'s birthday in %d days",contact.fullname,[contact.daysleft intValue]-1];
                    }

                }
            
            
            [componentsToSubtract setDay:1];
            fdate = [[NSCalendar currentCalendar] dateByAddingComponents:componentsToSubtract toDate:[NSDate date] options:0];
            NSDateComponents *components = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:fdate];
          
            NSDateComponents *components2 = [[NSDateComponents alloc] init];
            [components2 setYear:components.year];
            [components2 setMonth:components.month];
            [components2 setDay:components.day];
            [components2 setHour:fhour];
            [components2 setMinute:fmin];
            [components2 setSecond:00];
            
            // Generate a new NSDate from components3.
            NSDate *combinedDate = [gregorianCalendar dateFromComponents:components2];
            NSLog(@"FireDate : %@",combinedDate);
            [localNotification setFireDate:combinedDate];
            [localNotification setAlertAction:@"Launch"];
            [localNotification setAlertBody:alertBody];
            [localNotification setHasAction: YES];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            
            }
        }
    }
    else
        [[UIApplication sharedApplication ]cancelAllLocalNotifications];
}

-(void)refreshAllData
{
    
   // NSError *error;
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url =[url URLByAppendingPathComponent:@"Default Friends Database"];

    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    for (NSManagedObject *ct in [self.friendsDatabase.managedObjectContext registeredObjects])
    {
        [self.friendsDatabase.managedObjectContext deleteObject:ct];
    }
    self.friendsDatabase = [[ UIManagedDocument alloc] initWithFileURL:url];
    [self useDocument];
}

-(void)timechange
{

        [Friend refreshFriendDatabase:self.friendsDatabase.managedObjectContext];
        [Contact refreshFriendDatabase:self.friendsDatabase.managedObjectContext];
        [self setupFetchedResultsController];
        [self setupLocalNotifications];
}


#pragma mark - alertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Button Index : %d",buttonIndex);
    if (buttonIndex == 1)
    {
        NSMutableArray * fetchedObjectsMutable =[fetchedObjects mutableCopy];
        [fetchedObjectsMutable removeAllObjects];
        fetchedObjects = [NSArray arrayWithArray:fetchedObjectsMutable];
        [self.UpcomingBirthdaysTableView reloadData];
        
        [self refreshAllData];
    }
}


#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Error loading : %@",[error description]);
//    [bannerView setHidden:YES];
//    self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320, [[UIScreen mainScreen] bounds].size.height-160);
    
    if ([InternetCheck sharedInstance].internetWorking)
        
    {
        //loading revmob banner
        [[RevMobAds session] showBanner];
        [bannerView setDelegate:nil];
    }
    else
    {
        [bannerView setHidden:YES];
        self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320, [[UIScreen mainScreen] bounds].size.height-160);
    }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
    
    [[RevMobAds session] hideBanner];
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
    
}


#pragma mark - RevMobAdsDelegate methods

- (void)revmobAdDidFailWithError:(NSError *)error {
    NSLog(@"[RevMob Sample App] Ad failed: %@", error);
        [bannerView setHidden:YES];
    [bannerView setDelegate:nil];
        self.UpcomingBirthdaysTableView.frame = CGRectMake(0,160,320, [[UIScreen mainScreen] bounds].size.height-160);
}

//- (void)revmobAdDidReceive {
//    NSLog(@"[RevMob Sample App] Ad loaded.");
//}
//
//- (void)revmobAdDisplayed {
//    NSLog(@"[RevMob Sample App] Ad displayed.");
//}

@end
