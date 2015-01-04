//
//  NotificationsViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 1/4/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "NotificationsViewController.h"
#import "Notification+Parse.h"

@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(close)];
    self.navigationItem.leftBarButtonItem = back;

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)close {
    for (Notification *n in self.notificationsFetcher.fetchedObjects) {
        n.seen = @YES;
        [n saveOrUpdateToParseWithCompletion:nil];
    }

    [self notify:@"notifications:set" object:nil userInfo:@{@"count":@0}];

    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.notificationsFetcher sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.notificationsFetcher.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1];
    Notification *notification = [notificationsFetcher objectAtIndexPath:indexPath];
    label.text = notification.message;
    if ([notification.seen boolValue]) {
        label.font = [UIFont systemFontOfSize:16];
    }
    else {
        label.font = [UIFont boldSystemFontOfSize:17];
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSFetchedResultsController *)notificationsFetcher {
    if (notificationsFetcher)
        return notificationsFetcher;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = nil OR %K = 0", @"isDefault", @"isDefault"];
//    request.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedAt" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    notificationsFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:@"seen" cacheName:nil];
    [notificationsFetcher performFetch:nil];

    for (Notification *n in notificationsFetcher.fetchedObjects) {
        NSLog(@"%@ %@", n.seen, n.message);
    }
    return notificationsFetcher;

}
@end
