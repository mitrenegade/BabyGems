//
//  GemBoxViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemBoxViewController.h"
#import "Gem+Parse.h"
#import "GemCell.h"
#import "NewGemViewController.h"

@interface GemBoxViewController ()

@end

@implementation GemBoxViewController

static NSString * const reuseIdentifier = @"GemCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if !AIRPLANE_MODE
    self.collectionView.alpha = 0;
    if ([PFUser currentUser]) {
        self.collectionView.alpha = 1;
    }
    else {
        [_appDelegate goToLoginSignup];
    }
    [self listenFor:@"mainView:show" action:@selector(showMainView)];
#endif

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    [self stopListeningFor:@"mainView:show"];
}

-(void)showMainView {
    self.collectionView.alpha = 1;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoToAddGem"]) {
        UINavigationController *nav = [segue destinationViewController];
        NewGemViewController *controller = [nav.viewControllers lastObject];
        controller.delegate = self;
        newGemController = controller;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger objects = [[[self gemFetcher] fetchedObjects] count];
    return  objects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemCell" forIndexPath:indexPath];
    
    // Configure the cell
    if (indexPath.row < [self gemFetcher].fetchedObjects.count) {
        Gem *gem = [[self gemFetcher] objectAtIndexPath:indexPath];
        [cell setupForGem:gem];
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>

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

#pragma mark NewGemDelegate
-(void)didSaveNewGem {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.gemFetcher performFetch:nil];
        [self.collectionView reloadData];
        newGemController = nil;
    }];
}

#pragma mark Core Data
-(NSFetchedResultsController *)gemFetcher {
    if (__gemFetcher) {
        return __gemFetcher;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Gem"];
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"pfUserID", _currentUser.objectId];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    __gemFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [__gemFetcher performFetch:nil];

    return __gemFetcher;
}

@end
