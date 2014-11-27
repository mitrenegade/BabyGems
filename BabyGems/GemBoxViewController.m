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

@interface GemBoxViewController ()

@end

@implementation GemBoxViewController

static NSString * const reuseIdentifier = @"GemCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    [self listenFor:@"gems:updated" action:@selector(reloadData)];

    [self setupCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupCamera {
    UIButton *buttonQuote = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonQuote.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 150, 40, 40);
    [buttonQuote setImage:[UIImage imageNamed:@"quoteButton"] forState:UIControlStateNormal];
    buttonQuote.backgroundColor = [UIColor blackColor];
    buttonQuote.alpha = .9;
    buttonQuote.layer.cornerRadius = buttonQuote.frame.size.width/2;
    [self.view addSubview:buttonQuote];
    [buttonQuote addTarget:self action:@selector(goToQuote) forControlEvents:UIControlEventTouchUpInside];

    UIButton *buttonLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonLibrary.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 100, 40, 40);
    [buttonLibrary setImage:[UIImage imageNamed:@"polaroid"] forState:UIControlStateNormal];
    buttonLibrary.backgroundColor = [UIColor blackColor];
    buttonLibrary.alpha = .9;
    buttonLibrary.layer.cornerRadius = buttonLibrary.frame.size.width/2;
    [self.view addSubview:buttonLibrary];
    [buttonLibrary addTarget:self action:@selector(goToLibrary) forControlEvents:UIControlEventTouchUpInside];

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIButton *buttonPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonPhoto.frame = CGRectMake(self.view.frame.size.width - 60, self.view.frame.size.height - 50, 40, 40);
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
    GemCell *cell;
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemCell" forIndexPath:indexPath];

    // Configure the cell
    if (indexPath.row < [self gemFetcher].fetchedObjects.count) {
        Gem *gem = [[self gemFetcher] objectAtIndexPath:indexPath];

        if (gem.imageURL || gem.offlineImage) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemPhotoCell" forIndexPath:indexPath];
        }
        else {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemCell" forIndexPath:indexPath];
        }
        [cell setupForGem:gem];
    }
    else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GemCell" forIndexPath:indexPath];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static const NSInteger COMMENTS_HEIGHT = 50;
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
        UIFont *font = [UIFont fontWithName:@"Chalkduster" size:16];
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        return CGSizeMake(self.collectionView.frame.size.width, rect.size.height + 40 + COMMENTS_HEIGHT);
    }
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
//    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@", @"pfUserID", _currentUser.objectId];
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    fetchRequest.sortDescriptors = @[descriptor];
    __gemFetcher = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [__gemFetcher performFetch:nil];

    return __gemFetcher;
}

-(void)reloadData {
    [[self gemFetcher] performFetch:nil];
    [self.collectionView reloadData];
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

-(void)didTakePicture:(UIImage *)_image {
    savedImage = _image;
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
@end
