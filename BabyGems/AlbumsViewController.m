//
//  AlbumsViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "AlbumsViewController.h"
#import "AlbumCell.h"
#import "Album+Parse.h"

@interface AlbumsViewController ()

@end

@implementation AlbumsViewController

//static NSString * const reuseIdentifier = @"AlbumCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    // Do any additional setup after loading the view.

    // set section insets:
    //http://www.appcoda.com/supplementary-view-uicollectionview-flow-layout/

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else {
        return [[self.albumFetcher fetchedObjects] count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    // Configure the cell
    if (indexPath.section == 0) {
        if (indexPath.row == 0)
            [cell setupForDefaultAlbumWithGems:self.gemFetcher.fetchedObjects];
        else if (indexPath.row == 1)
            [cell setupForNewAlbum];
    }
    else {
        Album *album = [self.albumFetcher.fetchedObjects objectAtIndex:indexPath.row];
        [cell setupWithAlbum:album];
    }

    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // create a new album
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter album name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alert show];
        }
    }
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

#pragma mark NSFetchedResultsController

-(NSFetchedResultsController *) albumFetcher {
    if (albumFetcher)
        return albumFetcher;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Album"];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"pfUserID", _currentUser.objectId];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    albumFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [albumFetcher performFetch:nil];
    return albumFetcher;
}

-(NSFetchedResultsController *) gemFetcher {
    // returns gems without an album
    if (gemFetcher)
        return gemFetcher;

    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Gem"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = nil", @"album"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    gemFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [gemFetcher performFetch:nil];
    return gemFetcher;
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    }
    else if (buttonIndex == 1) {
        NSString *title = [alertView textFieldAtIndex:0].text;
        NSLog(@"Create an album with title %@", title);
        [self createAlbum:title];
    }
}

#pragma mark Album
-(void)createAlbum:(NSString *)title {
    Album *album = (Album *)[Album createEntityInContext:_appDelegate.managedObjectContext];
    album.startDate = [NSDate date];
    album.name = title;
#if AIRPLANE_MODE
    [_appDelegate saveContext];
    [UIAlertView alertViewWithTitle:@"Album created" message:@"Please add images to the album"];
    [self.albumFetcher performFetch:nil];
    [self.collectionView reloadData];
#else
    [album saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d id %@", success, album.parseID);
        [_appDelegate saveContext];
        [UIAlertView alertViewWithTitle:@"Album created" message:@"Please add images to the album"];
        [self.albumFetcher performFetch:nil];
        [self.collectionView reloadData];
    }];
#endif
}
@end
