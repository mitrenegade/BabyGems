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
#import "Gem+Info.h"
#import "UIActionSheet+MKBlockAdditions.h"

@interface GemBoxViewController ()

@end

@implementation GemBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(showSettings) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = right;

#if TESTING
    cellStyle = CellStyleFirst;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:cellstyle"]) {
        cellStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:cellstyle"];
    }
    borderStyle = BorderStyleFirst;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:borderstyle"]) {
        borderStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:borderstyle"];
    }
#else
    cellStyle = CellStyleBottom;
    borderStyle = BorderStyleRound;
#endif

    [self selectAlbum:self.currentAlbum];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        GemDetailViewController *controller = [segue destinationViewController];
        controller.borderStyle = borderStyle;
        controller.gem = (Gem *)sender;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"EmbedTutorial"]) {
        UIViewController *controller = [segue destinationViewController];
        tutorialView = controller.view;
        tutorialView.frame = self.collectionView.frame;
        [self.view insertSubview:tutorialView aboveSubview:self.collectionView];
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
    NSString *cellIdentifier;
    NSString *photoCellIdentifier;

    if (CellStyleFull == cellStyle) {
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
    if (indexPath.row < [self gemFetcher].fetchedObjects.count) {
        Gem *gem = [[self gemFetcher] objectAtIndexPath:indexPath];

        if (gem.imageURL || gem.offlineImage) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoCellIdentifier forIndexPath:indexPath];
        }
        else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        cell.borderStyle = borderStyle;
        [cell setupForGem:gem];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger COMMENTS_HEIGHT = 0;
    NSInteger LABEL_BORDER = 60;

    if (cellStyle == CellStyleBottom) {
        COMMENTS_HEIGHT = 50;
        LABEL_BORDER = 40;
    }
    else if (cellStyle == CellStyleFull) {
        COMMENTS_HEIGHT = 0;
        LABEL_BORDER = 60;
    }

    Gem *gem = [[self gemFetcher] objectAtIndexPath:indexPath];

    // photo gem
    if ([gem isPhotoGem]) {
        // check to see if surrounding gems are wide

        NSInteger width;
        NSInteger height;

        // todo: scale according to actual image dimensions
        float scale = 4.0/3.0;

        // this is the only gem
        if (self.gemFetcher.fetchedObjects.count == 1) {
            width = self.collectionView.frame.size.width;
            height = width * scale;
        }
        else {
            // default is half column width
            width = self.collectionView.frame.size.width/2;
            height = width * scale;

            if (indexPath.row == 0) {
                // there is a next gem
                Gem *nextGem = [[self gemFetcher] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                if (![nextGem isPhotoGem]) {
                    width = self.collectionView.frame.size.width;
                    height = width * scale;
                }
            }
            // this is the last gem
            else if (indexPath.row == self.gemFetcher.fetchedObjects.count - 1) {
                // there is a previous gem
                Gem *prevGem = [[self gemFetcher] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
                if (![prevGem isPhotoGem]) {
                    width = self.collectionView.frame.size.width;
                    height = width * scale;
                }
            }
            else {
                Gem *nextGem = [[self gemFetcher] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0]];
                Gem *prevGem = [[self gemFetcher] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
                if (![nextGem isPhotoGem] && ![prevGem isPhotoGem]) {
                    width = self.collectionView.frame.size.width;
                    height = width * scale;
                }
            }
        }

        return CGSizeMake(width, height + COMMENTS_HEIGHT);
    }
    else {
        NSString *text = gem.quote;
        UIFont *font = CHALK(16);
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        return CGSizeMake(self.collectionView.frame.size.width, rect.size.height + LABEL_BORDER + COMMENTS_HEIGHT);
    }
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Gem *gem = [[self gemFetcher] objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"GoToGemDetail" sender:gem];
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
-(NSFetchedResultsController *)gemFetcher {
    if (__gemFetcher) {
        return __gemFetcher;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Gem"];
    fetchRequest.predicate = albumPredicate;
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    __gemFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [__gemFetcher performFetch:nil];

    return __gemFetcher;
}

-(void)reloadData {
    [[self gemFetcher] performFetch:nil];
    [self.collectionView reloadData];

    if ([self.gemFetcher.fetchedObjects count] == 0) {
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

#pragma mark Alertview
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
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
            [controller saveGemWithQuote:savedQuote image:nil];
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

#pragma mark Settings
-(void)showSettings {
    NSString *message = [NSString stringWithFormat:@"About: BabyGems v%@\nCopyright 2014 Bobby Ren", VERSION];
    NSArray *menuOptions = @[@"Contact us", @"View website", @"Toggle photo options"];
#if TESTING
    menuOptions = [menuOptions arrayByAddingObject:@"Admin"];
#endif
    [UIActionSheet actionSheetWithTitle:message message:nil buttons:menuOptions showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            [self goToFeedback];
        }
        else if (buttonIndex == 1) {
            [self goToTOS];
        }
        else if (buttonIndex == 2) {
            [NewGemViewController toggleSaveToAlbum];
        }
        else {
#if TESTING
            [self showSettings];
#endif
        }
    } onCancel:^{
        // do nothing
    }];
}

#pragma mark Website
-(void)goToTOS {
    NSString *url = @"http://www.babygems.photos/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


#pragma mark Mail composer
-(void)goToFeedback {
    if ([MFMailComposeViewController canSendMail]){
        NSString *title = @"BabyGems feedback";
        NSString *message = [NSString stringWithFormat:@"Version %@", VERSION];
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setSubject:title];
        [composer setToRecipients:@[@"bobbyren+babygems@gmail.com"]];
        [composer setMessageBody:message isHTML:NO];

        [self presentViewController:composer animated:YES completion:nil];
    }
    else {
        [UIAlertView alertViewWithTitle:@"Currently unable to send email" message:@"Please make sure email is available"];
    }
}

#pragma mark MessageController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //feedbackMsg.text = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
            //feedbackMsg.text = @"Result: Mail saved";
            break;
        case MFMailComposeResultSent:
            //feedbackMsg.text = @"Result: Mail sent";
            [UIAlertView alertViewWithTitle:@"Thanks for your feedback" message:nil];
            break;
        case MFMailComposeResultFailed:
            //feedbackMsg.text = @"Result: Mail sending failed";
            [UIAlertView alertViewWithTitle:@"There was an error sending feedback" message:nil];
            break;
        default:
            //feedbackMsg.text = @"Result: Mail not sent";
            break;
    }
    // dismiss the composer
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark AlbumsViewController
-(void)selectAlbum:(Album *)album {
    if (album && album.parseID) {
        NSArray *results = [[Album where:@{@"parseID":album.parseID}] all];
        if (results)
            self.currentAlbum = [results firstObject];
        else
            self.currentAlbum = nil;
    }
    else {
        self.currentAlbum = album;
    }

    if (self.currentAlbum.parseID) {
        albumPredicate = [NSPredicate predicateWithFormat:@"%K = %@", @"album.parseID", self.currentAlbum.parseID];
    }
    else {
        albumPredicate = [NSPredicate predicateWithFormat:@"%K = nil", @"album.parseID"];
    }
    __gemFetcher = nil;
    [self.collectionView reloadData];
}

#pragma mark GemDetailDelegate
-(void)didMoveGem:(Gem *)gem toAlbum:(Album *)album {
    [self selectAlbum:album];
}

#pragma mark Admin settings
-(void)showAdmin {
    [UIActionSheet actionSheetWithTitle:@"Please select an option to toggle (in test mode)" message:nil buttons:@[@"Toggle cell style", @"Toggle cell border"] showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            [self toggleCellStyle];
        }
        else if (buttonIndex == 1) {
            [self toggleCellBorder];
        }
    } onCancel:^{
        // do nothing
    }];
}

-(void)toggleCellStyle {
    cellStyle += 1;
    if (cellStyle == CellStyleMax)
        cellStyle = CellStyleFirst;

    [[NSUserDefaults standardUserDefaults] setInteger:cellStyle forKey:@"defaults:cellstyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self reloadData];
}

-(void)toggleCellBorder {
    borderStyle += 1;
    if (borderStyle == BorderStyleMax)
        borderStyle = BorderStyleFirst;

    [[NSUserDefaults standardUserDefaults] setInteger:cellStyle forKey:@"defaults:borderstyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self reloadData];
}
@end
