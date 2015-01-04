//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import "GemBoxViewController.h"
#import "GemPhotoCell.h"
#import "Gem+Parse.h"
#import "GemCell.h"
#import "Gem+Info.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "GemDetailCollectionViewController.h"
#import "Album+Info.h"
#import "UICollectionView+Draggable.h"
#import "BackgroundHelper.h"
#import "NewGemViewController.h"
#import "UsersViewController.h"

#define ALERT_TAG_NEW_GEM 1
#define ALERT_TAG_RENAME_ALBUM 2

@interface GemBoxViewController ()
@end

@implementation GemBoxViewController

- (void)viewDidLoad
{
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    // Do any additional setup after loading the view.
    [self listenFor:@"gems:updated" action:@selector(reloadData)];

    [self setupCamera];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];

    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [tap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:tap];

    if (self.currentAlbum != [Album defaultAlbum]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = right;
    }

    if (self.currentAlbum.isOwned) {
        [self selectAlbum:self.currentAlbum];
    }
    else {
        [self loadSharedAlbum];
    }

    [self listenFor:@"style:changed" action:@selector(reloadData)];
    [self listenFor:@"album:changed" action:@selector(updateAlbum:)];
}

-(void)setupCamera {
    int offset = 0;
    if (TESTING || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        offset = 50;
    }
    UIButton *buttonQuote = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonQuote.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 150 - offset, 40, 40);
    [buttonQuote setImage:[UIImage imageNamed:@"quoteButton"] forState:UIControlStateNormal];
    buttonQuote.backgroundColor = [UIColor blackColor];
    buttonQuote.alpha = .9;
    buttonQuote.layer.cornerRadius = buttonQuote.frame.size.width/2;
    [self.view addSubview:buttonQuote];
    [buttonQuote addTarget:self action:@selector(goToQuote) forControlEvents:UIControlEventTouchUpInside];

    UIButton *buttonLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonLibrary.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 100 - offset, 40, 40);
    [buttonLibrary setImage:[UIImage imageNamed:@"polaroid"] forState:UIControlStateNormal];
    buttonLibrary.backgroundColor = [UIColor blackColor];
    buttonLibrary.alpha = .9;
    buttonLibrary.layer.cornerRadius = buttonLibrary.frame.size.width/2;
    [self.view addSubview:buttonLibrary];
    [buttonLibrary addTarget:self action:@selector(goToLibrary) forControlEvents:UIControlEventTouchUpInside];

    if (TESTING || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIButton *buttonPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonPhoto.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 50 - offset, 40, 40);
        [buttonPhoto setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        buttonPhoto.backgroundColor = [UIColor blackColor];
        buttonPhoto.alpha = .9;
        buttonPhoto.layer.cornerRadius = buttonPhoto.frame.size.width/2;
        [self.view addSubview:buttonPhoto];
        [buttonPhoto addTarget:self action:@selector(goToCamera) forControlEvents:UIControlEventTouchUpInside];
    }

}

-(void)selectAlbum:(Album *)album {
    if (album && album.parseID) {
        NSArray *results = [[Album where:@{@"parseID":album.parseID}] all];
        if (results) {
            self.currentAlbum = [results firstObject];
            [[NSUserDefaults standardUserDefaults] setObject:album.parseID forKey:@"album:last:opened"];
        }
        else {
            self.currentAlbum = nil;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"album:last:opened"];
        }
    }
    else {
        self.currentAlbum = album;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"album:last:opened"];
    }

    [self.collectionView reloadData];

    if (self.currentAlbum.name) {
        self.title = self.currentAlbum.name;
    }
    else {
        if (self.currentAlbum.isOwned)
            self.title = @"My GemBox";
        else
            self.title = @"Shared album";
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (albumCoverNeedsUpdate) {
        [self notify:@"album:changed" object:nil userInfo:@{@"album":self.currentAlbum}];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"GoToAddGem"]) {
        NewGemViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.image = savedImage;
        controller.quote = savedQuote;
        controller.meta = savedMeta;
    }
    else if ([segue.identifier isEqualToString:@"GoToGemDetail"]) {
        GemDetailCollectionViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        Gem *gem = (Gem *)sender;
        NSInteger index = [[self.currentAlbum sortedGems] indexOfObject:gem];
        [controller setInitialPage:index];
    }
    else if ([segue.identifier isEqualToString:@"EmbedTutorial"]) {
        UIViewController *controller = [segue destinationViewController];
        tutorialView = controller.view;
        tutorialView.frame = self.collectionView.frame;
        [self.view insertSubview:tutorialView aboveSubview:self.collectionView];
    }
    else if ([segue.identifier isEqualToString:@"GemBoxToShare"]) {
        UsersViewController *controller = [segue destinationViewController];
        controller.album = self.currentAlbum;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger objects = [self.currentAlbum.gems count]; //[[[self gemFetcher] fetchedObjects] count];
    return  objects;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier;
    NSString *photoCellIdentifier;

    if (CellStyleFull == _appDelegate.cellStyle) {
        cellIdentifier = @"GemFullCell";
        photoCellIdentifier = @"GemFullPhotoCell";
    }
    else {
        cellIdentifier = @"GemCell";
        photoCellIdentifier = @"GemPhotoCell";
    }

    GemCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    // Configure the cell
    if (indexPath.row < [self currentAlbum].gems.count) {
        Gem *gem = [self.currentAlbum.sortedGems objectAtIndex:indexPath.row]; //[[self gemFetcher] objectAtIndexPath:indexPath];

        if (gem.imageURL || gem.offlineImage) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
        }
        else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        cell.borderStyle = _appDelegate.borderStyle;
        [cell setupForGem:gem];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    NSLog(@"Row %d %@", indexPath.row, cell.labelQuote.text);

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger COMMENTS_HEIGHT = 0;
    NSInteger LABEL_BORDER = 60;

    if (_appDelegate.cellStyle == CellStyleBottom) {
        COMMENTS_HEIGHT = 50;
        LABEL_BORDER = 40;
    }
    else if (_appDelegate.cellStyle == CellStyleFull) {
        COMMENTS_HEIGHT = 0;
        LABEL_BORDER = 60;
    }

    NSInteger width;
    NSInteger height;

    // todo: scale according to actual image dimensions
    // this is the only gem
    // default is half column width
    width = self.collectionView.frame.size.width/2 - 5;
    height = width;

    return CGSizeMake(width, height + COMMENTS_HEIGHT);

}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentAlbum.isOwned)
        return YES;
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
// Prevent item from being moved to index 0
//    if (toIndexPath.item == 0) {
//        return NO;
//    }
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *gems = [[self sortedGems] mutableCopy];
    NSInteger currPos = fromIndexPath.row;
    NSInteger newPos = toIndexPath.row;
    if (currPos == newPos)
        return;
    Gem *gem = [gems objectAtIndex:currPos];
    [gems removeObjectAtIndex:currPos];
    [gems insertObject:gem atIndex:MIN(newPos, [gems count])];

    // updateGemOrder
    for (int i=0; i<[gems count]; i++) {
        Gem *gem = gems[i];
        gem.order = @(i);
        [gem saveOrUpdateToParseWithCompletion:nil];
    }
    gem.album.customOrder = @YES;
    [gem.album saveOrUpdateToParseWithCompletion:nil];
    [_appDelegate saveContext];

    albumCoverNeedsUpdate = YES;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Gem *gem = [[self.currentAlbum sortedGems] objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"GoToGemDetail" sender:gem];
}

#pragma mark NewGemDelegate
-(void)didSaveNewGem {
    [self.navigationController popViewControllerAnimated:YES];
    [self reloadData];
    cameraController = nil;
}
-(void)dismissNewGem {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Core Data
-(void)reloadData {
    //    __gemFetcher = nil;
    //    [[self gemFetcher] performFetch:nil];
    [self.collectionView reloadData];

    if ([self.currentAlbum.gems count] == 0) {
        [self performSegueWithIdentifier:@"EmbedTutorial" sender:self];
        [tutorialView setHidden:NO];
    }
    else {
        [tutorialView setHidden:YES];
    }
}

#pragma mark New Gem
-(void)goToQuote {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a Gem" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Add photo", @"Save gem", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = ALERT_TAG_NEW_GEM;
    [alert show];
}

-(void)goToCamera {
    cameraController = [[CameraViewController alloc] init];
    cameraController.delegate = self;
    [cameraController showCameraFromController:self];
}

-(void)didTakePicture:(UIImage *)image meta:(NSDictionary *)meta {
    savedImage = image;
    savedMeta = meta;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"GoToAddGem" sender:self];
    }];
}

-(void)goToLibrary {
    cameraController = [[CameraViewController alloc] init];
    cameraController.delegate = self;
    [cameraController showLibraryFromController:self];
}

-(void)didTakeMultiplePictures:(NSArray *)images meta:(NSArray *)meta {

    [BackgroundHelper keepTaskInBackgroundForPhotoUpload];
    __block int complete_count = 0;
    for (int i=0; i<[images count]; i++) {
        UIImage *image = images[i];
        NSDictionary *info = meta[i];

        Gem *gem;
        if (!gem) {
            gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
        }
        gem.createdAt = [NSDate date];

        // allow offline image storage
        NSData *data = UIImageJPEGRepresentation(image, .8);
        gem.offlineImage = data;
        gem.album = self.currentAlbum;

        [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
            NSLog(@"Success %d", success);

            // online image storage
            PFFile *imageFile = [PFFile fileWithData:data];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [gem.pfObject setObject:imageFile forKey:@"imageFile"];
                gem.imageURL = imageFile.url;
                [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
                    complete_count++;
                    if (complete_count == [images count]) {
                        // did save multiple gems
                        [BackgroundHelper stopTaskInBackgroundForPhotoUpload];
                        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                        [self reloadData];
                        cameraController = nil;

                        // offline storage
                        [_appDelegate.managedObjectContext save:nil];
                    }
                }];
            }];
        }];

        if (image && [NewGemViewController canSaveToAlbum]) {
            [NewGemViewController saveToAlbum:image meta:info];
        }
    }
}

#pragma mark Alertview
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }

    if (alertView.tag == ALERT_TAG_RENAME_ALBUM) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [self renameAlbum:textField.text];
    }
    else if (alertView.tag == ALERT_TAG_NEW_GEM) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        savedQuote = textField.text;

        if (buttonIndex == 1) {
            savedImage = nil;
            [self goToCamera];
        }
        else if (buttonIndex == 2) {
            // save quote only
            if ([savedQuote length]) {
                NewGemViewController *controller = [[NewGemViewController alloc] init];
                controller.delegate = self;
                [controller saveGemWithQuote:savedQuote image:nil album:self.currentAlbum];
            }
        }
    }
}

#pragma mark Swipe gestures
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
        if ([(UISwipeGestureRecognizer *)gesture direction] == UISwipeGestureRecognizerDirectionLeft) {
            // swipe left = camera
            [self goToCamera];
        }
        else if ([(UISwipeGestureRecognizer *)gesture direction] == UISwipeGestureRecognizerDirectionRight) {
            // swipe right = library
            [self goToLibrary];
        }
    }
    else if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        [self goToQuote];
    }
}

-(void)showSettings {
    NSArray *options = @[@"Sharing", @"Rename album", @"Delete album"];
    [UIAlertView alertViewWithTitle:@"Album options" message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:options onDismiss:^(int buttonIndex) {
        if (buttonIndex == [options indexOfObject:@"Rename album"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter a new album name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Rename", nil];
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            alert.tag = ALERT_TAG_RENAME_ALBUM;
            [alert show];
        }
        else if (buttonIndex == [options indexOfObject:@"Delete album"]) {
            [UIAlertView alertViewWithTitle:@"Delete album?" message:[NSString stringWithFormat:@"Are you sure you want to delete the album %@?", self.currentAlbum.name] cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Delete"] onDismiss:^(int buttonIndex) {
                [self deleteAlbum:self.currentAlbum];
            } onCancel:nil];
        }
        else if (buttonIndex == [options indexOfObject:@"Sharing"]) {
            [self performSegueWithIdentifier:@"GemBoxToShare" sender:self];
        }
    } onCancel:nil];
}

-(void)renameAlbum:(NSString *)title {
    self.currentAlbum.name = title;
    [self.currentAlbum saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d id %@", success, self.currentAlbum.parseID);
        self.title = title;
        [_appDelegate saveContext];
        NSDictionary *userInfo = @{@"album":self.currentAlbum};
        [self notify:@"album:changed" object:nil userInfo:userInfo];
    }];
}

-(void)deleteAlbum:(Album *)album {
    // todo: what happens to all the photos?
    [album.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_appDelegate.managedObjectContext deleteObject:album];
        [self notify:@"album:deleted"];
        [self.navigationController popViewControllerAnimated:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"album:last:opened"];
    }];
}

-(void)updateAlbum:(NSNotification *)n {
    // if gemDetail moves a photo to an album, that changes this album
    Album *album = [n.userInfo valueForKey:@"album"];
    [self selectAlbum:album];
}

#pragma mark GemDetailCollectionDelegate
// uses all the same album structures
-(NSArray *)sortedGems {
    return [self.currentAlbum sortedGems];
}

-(Gem *)gemAtIndexPath:(NSIndexPath *)indexPath {
    return [[self.currentAlbum sortedGems] objectAtIndex:indexPath.row];
}

#pragma mark Shared albums
-(void)loadSharedAlbum {
    // inefficient for now - load gems for album each time
    PFQuery *query = [PFQuery queryWithClassName:@"Gem"];
    if (!self.currentAlbum || !self.currentAlbum.pfObject)
        return;
    
    [query whereKey:@"album" equalTo:self.currentAlbum.pfObject];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            [ParseBase synchronizeClass:@"Gem" fromObjects:objects replaceExisting:NO completion:^{
                NSLog(@"Objects: %@", objects);
                NSLog(@"Album's gems: %lu", (unsigned long)[self.currentAlbum.gems count]);

                [self selectAlbum:self.currentAlbum];
            }];
        }
    }];}

@end
