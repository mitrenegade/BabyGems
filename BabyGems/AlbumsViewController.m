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
#import "GemBoxViewController.h"
#import "Album+Info.h"

#define ALERT_TAG_NEW_ALBUM 1
#define ALERT_TAG_RENAME_ALBUM 2

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

    if (self.mode == AlbumsViewModeNormal) {
        self.title = @"All albums";
    }
    else {
        self.title = @"Move to album";
    }

    [self listenFor:@"album:changed" action:@selector(changeAlbum:)];
    [self listenFor:@"gems:updated" action:@selector(reloadAlbums)];
    [self listenFor:@"sync:complete" action:@selector(reloadAlbums)];
    [self listenFor:@"album:deleted" action:@selector(reloadAlbums)];

    if (self.mode == AlbumsViewModeNormal) {
        NSString *lastAlbumID = [[NSUserDefaults standardUserDefaults] objectForKey:@"album:last:opened"];
        if (lastAlbumID) {
            NSArray *results = [[Album where:@{@"parseID":lastAlbumID}] all];
            if ([results count]) {
                self.currentAlbum = [results firstObject];
                [self performSegueWithIdentifier:@"AlbumsToGemBox" sender:nil];
            }
        }
    }

    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = right;

    [self.collectionView setDraggable:YES]; // don't allow drag, but use all other functionality of LSCollectionViewHelper
}

-(void)showSettings {
    [_appDelegate showSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"AlbumsToGemBox"]) {
        GemBoxViewController *controller = [segue destinationViewController];
        controller.currentAlbum = self.currentAlbum;
    }
}

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
        if (indexPath.row == 0) {
            Album *album = [Album defaultAlbum];
            [cell setupWithAlbum:album];
            if (album == self.currentAlbum || (album.parseID && [album.parseID isEqualToString:self.currentAlbum.parseID])) {
                [cell isCurrentAlbum];
            }
        }
        else if (indexPath.row == 1)
            [cell setupForNewAlbum];
    }
    else {
        Album *album = [self.albumFetcher.fetchedObjects objectAtIndex:indexPath.row];
        [cell setupWithAlbum:album];
        if (album == self.currentAlbum || (album.parseID && [album.parseID isEqualToString:self.currentAlbum.parseID])) {
            [cell isCurrentAlbum];
        }
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
            alert.tag = ALERT_TAG_NEW_ALBUM;
            [alert show];
        }
        else {
            // view default album
            Album *album = [Album defaultAlbum];
            self.currentAlbum = album;

            if (self.mode == AlbumsViewModeSelect && self.delegate)
                [self.delegate didSelectAlbum:self.currentAlbum];
            else {
//                [self performSegueWithIdentifier:@"AlbumsToGemBoxCollection" sender:nil];
                [self performSegueWithIdentifier:@"AlbumsToGemBox" sender:nil];
            }
            [self.collectionView reloadData];
        }
    }
    else {
        if (indexPath.row < [[self.albumFetcher fetchedObjects] count]) {
            Album *album = [self.albumFetcher.fetchedObjects objectAtIndex:indexPath.row];
            self.currentAlbum = album;

            if (self.mode == AlbumsViewModeSelect && self.delegate)
                [self.delegate didSelectAlbum:self.currentAlbum];
            else
                [self performSegueWithIdentifier:@"AlbumsToGemBox" sender:nil];
            [self.collectionView reloadData];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(1, 5);
}

#pragma mark DraggableCollectionView stuff
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    // don't allow drag, but do a side behavior
    Album *album;
    if (indexPath.section == 0) {
        NSString *title = indexPath.row == 0? @"Go to default album":@"Create new album";
        [UIAlertView alertViewWithTitle:title message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex) {
            [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
        } onCancel:nil];
        return NO;
    }
    else {
        album = [self.albumFetcher.fetchedObjects objectAtIndex:indexPath.row];
    }

    [UIAlertView alertViewWithTitle:@"Album options" message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Rename album", @"Delete album"] onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            renameAlbum = album;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a new album name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERT_TAG_RENAME_ALBUM;
            [alert show];
        }
        else if (buttonIndex == 1) {
            [UIAlertView alertViewWithTitle:@"Delete album?" message:[NSString stringWithFormat:@"Are you sure you want to delete the album %@?", album.name] cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {
                [self deleteAlbum:album];
            } onCancel:nil];
        }
    } onCancel:nil];
    return NO;
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = nil OR %K = 0", @"isDefault", @"isDefault"];
    request.predicate = predicate;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    request.sortDescriptors = @[sortDescriptor];
    albumFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [albumFetcher performFetch:nil];
    return albumFetcher;
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Cancel");
    }
    else if (buttonIndex == 1) {
        NSString *title = [alertView textFieldAtIndex:0].text;
        NSLog(@"Alert input: %@", title);
        if (alertView.tag == ALERT_TAG_NEW_ALBUM)
            [self createAlbum:title];
        else if (alertView.tag == ALERT_TAG_RENAME_ALBUM)
            [self renameAlbum:title];
    }
}

#pragma mark Album
-(void)createAlbum:(NSString *)title {
    Album *album = (Album *)[Album createEntityInContext:_appDelegate.managedObjectContext];
    album.startDate = [NSDate date];
    album.name = title;
    self.currentAlbum = album;

#if AIRPLANE_MODE
    [_appDelegate saveContext];
    [UIAlertView alertViewWithTitle:@"Album created" message:@"Please add images to the album"];
    [self.albumFetcher performFetch:nil];
    [self.collectionView reloadData];

    // select album and pop
    if (self.mode == AlbumsViewModeSelect && self.delegate)
        [self.delegate didSelectAlbum:album];
    else
        [self performSegueWithIdentifier:@"AlbumsToGemBox" sender:nil];
#else
    [album saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d id %@", success, album.parseID);
        [_appDelegate saveContext];
        [UIAlertView alertViewWithTitle:@"Album created" message:@"Please add images to the album"];
        [self.albumFetcher performFetch:nil];
        [self.collectionView reloadData];

        // select album and pop
        if (self.mode == AlbumsViewModeSelect && self.delegate)
            [self.delegate didSelectAlbum:album];
        else
            [self performSegueWithIdentifier:@"AlbumsToGemBox" sender:nil];
    }];
#endif
}

-(void)renameAlbum:(NSString *)title {
    renameAlbum.name = title;
    [renameAlbum saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d id %@", success, renameAlbum.parseID);
        [_appDelegate saveContext];
        [self.albumFetcher performFetch:nil];
        [self.collectionView reloadData];
    }];
}

-(void)deleteAlbum:(Album *)album {
    [album.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_appDelegate.managedObjectContext deleteObject:album];
        [self.albumFetcher performFetch:nil];
        [self.collectionView reloadData];
    }];
}

#pragma mark notifications
-(void)reloadAlbums {
    albumFetcher = nil;
    [self.albumFetcher performFetch:nil];
    [self.collectionView reloadData];
}

-(void)changeAlbum:(NSNotification *)n {
    // if gemDetail moves a photo to an album, that changes this album
    Album *album = [n.userInfo valueForKey:@"album"];
    self.currentAlbum = album;
    [self.collectionView reloadData];
}
@end
