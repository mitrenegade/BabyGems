//
//  UsersViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;

@interface UsersViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSArray *allUsers;
    NSMutableSet *sharedIDs;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) Album *album;
@end
