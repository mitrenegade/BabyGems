//
//  UsersViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "UsersViewController.h"
#import "UserCell.h"
#import "Album+Info.h"

@interface UsersViewController ()

@end

@implementation UsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadUsers {
    // for now, load all users on babygems
    PFQuery *query = [PFUser query];
    PFUser *user = _currentUser;
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

#pragma mark TableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [allUsers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
    [cell setupWithUser:[allUsers objectAtIndex:indexPath.row]];
    [cell toggleSelected:NO];

    // todo: check current album for permissions for existing users
    
    return cell;
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
