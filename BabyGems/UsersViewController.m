//
//  UsersViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "UsersViewController.h"
#import "UserCell.h"
#import "Album+Parse.h"
#import "Notification+Parse.h"

@interface UsersViewController ()

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    sharedUsers = [NSMutableSet set];
    allUsers = [NSMutableSet set];
    [self loadAlbumUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUsersWithKeywords:(NSString *)keywordString {
    // keywordString may be a name, a full name, or an email
    NSArray *keywords = [keywordString componentsSeparatedByString:@" "];

    PFQuery *query = [PFUser query];
    [query whereKey:@"canonicalEmail" containsString:keywordString];

    for (NSString *keyword in keywords) {
        PFQuery *subquery = [PFUser query];
        [subquery whereKey:@"canonicalFullName" containsString:keyword];
        query = [PFQuery orQueryWithSubqueries:@[query, subquery]];
    }

    [query whereKey:@"objectId" notEqualTo:_currentUser.objectId];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Results: %lu users", [objects count]);
            [allUsers removeAllObjects];
            [allUsers addObjectsFromArray:objects];
            [self combineUsers];
            [self.tableView reloadData];
        }
    }];
}

-(void)loadAlbumUsers {
    PFRelation *relation = [self.album.pfObject relationForKey:@"sharedWith"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [sharedUsers removeAllObjects];
        for (PFUser *user in objects) {
            [sharedUsers addObject:user];
        }
        [self combineUsers];
        [self.tableView reloadData];
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self loadUsersWithKeywords:[searchBar.text lowercaseString]];
}

-(void)combineUsers {
    for (PFUser *user in sharedUsers) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != %@", @"objectId", user.objectId];
        [allUsers filterUsingPredicate:predicate];
    }
    [allUsers unionSet:sharedUsers];
}
-(NSArray *)sortedUsers {
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"canonicalFullName" ascending:YES];
    NSArray *sorted = [allUsers sortedArrayUsingDescriptors:@[sort]];
    return sorted;
}

#pragma mark TableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sortedUsers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    PFUser *user = [self.sortedUsers objectAtIndex:indexPath.row];
    [cell setupWithUser:user];
    [cell toggleSelected:[sharedUsers containsObject:user]];

    // todo: check current album for permissions for existing users
    
    return cell;
}

#pragma mark tableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [self.sortedUsers objectAtIndex:indexPath.row];
    PFRelation *relation = [self.album.pfObject relationForKey:@"sharedWith"];

    if ([sharedUsers containsObject:user]) {
        // remove
        [relation removeObject:user];
        [self.album.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [sharedUsers removeObject:user];
            [self.tableView reloadData];

            [self removeShareNotificationForAlbum:self.album user:user];
        }];
    }
    else {
        [relation addObject:user];
        [self.album.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [sharedUsers addObject:user];
            [self.tableView reloadData];

            [self createShareNotificationForAlbum:self.album user:user];
        }];
    }
}

-(void)createShareNotificationForAlbum:(Album *)album user:(PFUser *)user {
    NSDictionary *info = @{@"toUserID":user.objectId, @"itemID":album.parseID};
    [Notification queryForInfo:info completion:^(NSArray *results, NSError *error) {
        if (![results count]) {
            // create a notification
            Notification *notification = [Notification createEntityInContext:_appDelegate.managedObjectContext];
            notification.message = [NSString stringWithFormat:@"You have been added to %@'s album", user.username];
            notification.seen = @NO;
            notification.toUserID = user.objectId;
            notification.itemID = album.parseID;

            [notification saveOrUpdateToParseWithCompletion:^(BOOL success) {
                NSLog(@"Created notification");
            }];
        }
        else {
            Notification *notification = [Notification fromPFObject:[results firstObject]];
            notification.seen = @NO;
            notification.updatedAt = [NSDate date];
            [notification saveOrUpdateToParseWithCompletion:^(BOOL success) {
                NSLog(@"Updated notification");
            }];
        }
    }];
}

-(void)removeShareNotificationForAlbum:(Album *)album user:(PFUser *)user {
    NSDictionary *info = @{@"toUserID":user.objectId, @"itemID":album.parseID};
    [Notification queryForInfo:info completion:^(NSArray *results, NSError *error) {
        if (![results count]) {
            return;
        }
        else {
            PFObject *notification = [results firstObject];
            [notification deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Notification deleted");
                }
            }];
        }
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
