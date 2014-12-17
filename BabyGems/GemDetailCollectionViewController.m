//
//  GemDetailCollectionViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 12/16/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemDetailCollectionViewController.h"
#import "GemDetailCell.h"
#import "Album+Info.h"
#import "Gem.h"

@interface GemDetailCollectionViewController ()

@end

@implementation GemDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.initialPage >= 0) {
        [self goToPage:self.initialPage animated:NO];
        self.initialPage = -1;
    }
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
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.delegate sortedGems] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GemDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemDetailCell" forIndexPath:indexPath];
    cell.delegate = self;

    // Configure the cell
    if (indexPath.row == 0 && self.initialPage >= 0) {
        // hack to make it look like we start on the selected page. cell 0 loads the selected page, then the collectionview
        // jumps to that actual page, and cell 0 is allowed to load its actual image.
        [cell setupWithGem:[self.delegate gemAtIndexPath:[NSIndexPath indexPathForRow:self.initialPage inSection:0]]];
    }
    else {
        [cell setupWithGem:[self.delegate gemAtIndexPath:indexPath]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
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

-(void)goToPage:(NSInteger)page animated:(BOOL)animated {
    CGPoint offset = CGPointMake(page * self.collectionView.frame.size.width, 0);
    if (animated) {
        [UIView animateWithDuration:1 animations:^{
            [self.collectionView setContentOffset:offset];
        }];
    }
    else {
        [self.collectionView setContentOffset:offset];
    }
}

#pragma mark GemDetailDelegate
-(void)didDeleteGem:(Gem *)gem {
    [self notify:@"album:changed" object:nil userInfo:@{@"album":gem.album}];
    [self.collectionView reloadData];
}

-(void)didMoveGem:(Gem *)gem toAlbum:(Album *)album {
    [self.collectionView reloadData];
    [self notify:@"album:changed" object:nil userInfo:@{@"album":album}];
}

-(void)shareGem:(id)gem {
    NSLog(@"Share!");
    // use action sheet
    /*
     Activity types:
     NSString *const UIActivityTypePostToFacebook;
     NSString *const UIActivityTypePostToTwitter;
     NSString *const UIActivityTypePostToWeibo;
     NSString *const UIActivityTypeMessage;
     NSString *const UIActivityTypeMail;
     NSString *const UIActivityTypePrint;
     NSString *const UIActivityTypeCopyToPasteboard;
     NSString *const UIActivityTypeAssignToContact;
     NSString *const UIActivityTypeSaveToCameraRoll;
     NSString *const UIActivityTypeAddToReadingList;
     NSString *const UIActivityTypePostToFlickr;
     NSString *const UIActivityTypePostToVimeo;
     NSString *const UIActivityTypePostToTencentWeibo;
     NSString *const UIActivityTypeAirDrop;
     */

    /*

    NSString *textToShare = gem.quote.length?self.labelQuote.text:nil;
    UIImage *image;
    if (self.imageView.image)
        image = self.imageView.image;
    else if (self.gem.offlineImage)
        image = [UIImage imageWithData:self.gem.offlineImage];
    UIImage *imageToShare = image;
    NSMutableArray *itemsToShare = [NSMutableArray array];
    if (textToShare)
        [itemsToShare addObject:textToShare];
    if (imageToShare)
        [itemsToShare addObject:imageToShare];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeAddToReadingList, UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo]; //or whichever you don't need
    activityVC.completionHandler = ^(NSString *activityType, BOOL completed) {
        if (!activityType)
            return;
        NSLog(@"shared with activity: %@ completed: %d", activityType, completed);
    };
    [self.navigationController presentViewController:activityVC animated:YES completion:nil];
     */
}
@end
