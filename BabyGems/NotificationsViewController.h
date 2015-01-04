//
//  NotificationsViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 1/4/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsViewController : UITableViewController
{
    NSFetchedResultsController *notificationsFetcher;
}

-(NSFetchedResultsController *)notificationsFetcher;
@end
