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

    sharedIDs = [NSMutableSet set];
    [self loadUsers];
    [self loadAlbumUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUsers {
    // for now, load all users on babygems
    PFQuery *query = [PFUser query];
    [query whereKey:@"pfUserID" notEqualTo:_currentUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            allUsers = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)loadAlbumUsers {
    PFRelation *relation = [self.album.pfObject relationForKey:@"sharedWith"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [sharedIDs removeAllObjects];
        for (PFUser *user in objects) {
            [sharedIDs addObject:user.objectId];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark TableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allUsers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    PFUser *user = [allUsers objectAtIndex:indexPath.row];
    [cell setupWithUser:user];
    [cell toggleSelected:[sharedIDs containsObject:user.objectId]];

    // todo: check current album for permissions for existing users
    
    return cell;
}

#pragma mark tableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = [allUsers objectAtIndex:indexPath.row];
    PFRelation *relation = [self.album.pfObject relationForKey:@"sharedWith"];

    if ([sharedIDs containsObject:user.objectId]) {
        // remove
        [relation removeObject:user];
        [self.album.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [sharedIDs removeObject:user.objectId];
            [self.tableView reloadData];

            [self removeShareNotificationForAlbum:self.album user:user];
        }];
    }
    else {
        [relation addObject:user];
        [self.album.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [sharedIDs addObject:user.objectId];
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
