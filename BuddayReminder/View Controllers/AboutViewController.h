//
//  AboutViewController.h
//  BuddayReminder
//
//  Created by Ankit on 30/09/13.
//  Copyright (c) 2013 EntropyUnlimited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AboutViewController : UIViewController<ADBannerViewDelegate>
{
    
    __weak IBOutlet ADBannerView *bannerView;
}
@end
