//
//  NewGemViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import "NewGemViewController.h"
#import "UIImage+Resize.h"
#import "Gem+Parse.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"

@interface NewGemViewController ()

@end

#define PLACEHOLDER_TEXT @"Enter your gem here"

@implementation NewGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(didClickSave:)];
    self.navigationItem.rightBarButtonItem = right;
    [self enableButtons:NO];

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* button1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self.inputQuote action:@selector(resignFirstResponder)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* button2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditQuote)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:button2, flex, button1, nil]];
    if (IS_ABOVE_IOS6) {
        [keyboardDoneButtonView setTintColor:[UIColor whiteColor]];
    }
    self.inputQuote.inputAccessoryView = keyboardDoneButtonView;
    self.inputQuote.text = PLACEHOLDER_TEXT;

    imageFileReady = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.imageView addGestureRecognizer:tap];

    if (self.image)
        [self updateGemImage];
    if (self.quote)
        self.inputQuote.text = self.quote;

    [self updateTextSize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)enableButtons:(BOOL)enabled {
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

-(void)didClickSave:(id)sender {
    [self saveGem];
}

#pragma mark Textview delegate
-(void)cancelEditQuote {
    self.inputQuote.text = self.quote;
    if ([self.inputQuote.text length] == 0) {
        [self.inputQuote setText:PLACEHOLDER_TEXT];
        self.quote = nil;
    }
    [self.inputQuote resignFirstResponder];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.inputQuote setText:self.quote];
    [self updateTextSize];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.inputQuote resignFirstResponder];
    if ([self.inputQuote.text length] == 0 || [self.inputQuote.text isEqualToString:PLACEHOLDER_TEXT]) {
        [self.inputQuote setText:PLACEHOLDER_TEXT];
        self.quote = nil;
    }
    else {
        self.quote = self.inputQuote.text;
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.inputQuote resignFirstResponder];
    if (self.quote.length) {
        [self enableButtons:YES];
    }
    else {
        [self enableButtons:NO];
    }
}

-(void)textViewDidChange:(UITextView *)textView {
    [self updateTextSize];
}

-(void)updateTextSize {
    CGRect rect = [self.inputQuote.text boundingRectWithSize:CGSizeMake(self.inputQuote.frame.size.width, 250) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.inputQuote.font} context:nil];
    self.constraintQuoteHeight.constant = rect.size.height + 40;
}

#pragma mark Camera
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    cameraController = [[CameraViewController alloc] init];
    cameraController.delegate = self;
    [cameraController showCameraFromController:self];
}

-(void)didTakePicture:(UIImage *)image {
    self.image = image;
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self updateGemImage];
    }];
}

-(void)updateGemImage {
    if (!self.image)
        return;

    self.imageView.image = self.image;
    imageFileReady = NO;
    [self enableButtons:NO];

    if (!gem) {
        gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
    }

    // allow offline image storage
    NSData *data = UIImageJPEGRepresentation(self.image, .8);
    gem.offlineImage = data;

    // online image storage
    imageFile = [PFFile fileWithData:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        imageFileReady = YES;
        [self enableButtons:YES];
    }];
}

#pragma mark Parse
-(void)saveGem {
    [self saveGemWithQuote:self.quote image:self.image];
    [self.delegate didSaveNewGem];
}

-(void)saveGemWithQuote:(NSString *)quote image:(UIImage *)image {
    [self enableButtons:NO];

    if (!gem) {
        gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
    }

    gem.quote = quote;
    if (imageFileReady) {
        gem.imageURL = [imageFile url];

        // also add a pointer to the PFFile if possible
        if (gem.pfObject)
            [gem.pfObject setObject:imageFile forKey:@"imageFile"];
    }
    else {
        // todo: set a flag to do image upload later when internet is ready
    }
    gem.createdAt = [NSDate date];

    [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d", success);
        [self enableButtons:YES];
        [self notify:@"gems:updated"];

        if (imageFile) {
            [gem.pfObject setObject:imageFile forKey:@"imageFile"];
            [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
                [self notify:@"gems:updated"];
            }];
        }
    }];

    // offline storage
    [_appDelegate.managedObjectContext save:nil];

    if (self.image)
        [self saveScreenshot];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    CGSize keyboardSize = [[n.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.constraintQuoteDistanceFromBottom.constant = keyboardSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHide:(NSNotification *)n {
    self.constraintQuoteDistanceFromBottom.constant = 40;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Navigation
-(void)didClickGemBox:(id)sender {
    [self.delegate dismissNewGem];
}

#pragma mark saveToAlbum
-(void)saveScreenshot {
    // Create the screenshot. draw image in viewBounds
    //    if (isPortrait) {
    //        [self.canvas setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    //    }
    float scaleX = self.image.size.width / self.imageView.frame.size.width;
    float scaleY = self.image.size.height / self.imageView.frame.size.height;

    if ([self.quote length] == 0)
        [self.inputQuote setHidden:YES];

    CGAffineTransform t = CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY);
    CGSize size = self.image.size;
    UIGraphicsBeginImageContext(size);

    // Put everything in the current view into the screenshot
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextConcatCTM(ctx, t);
    /*
    if (isPortrait) {
        CGAffineTransform r = CGAffineTransformMakeRotation(M_PI_2);
        CGAffineTransform dx = CGAffineTransformMakeTranslation(0, -320);
        CGContextConcatCTM(ctx, r);
        CGContextConcatCTM(ctx, dx);
    }
     */
    [self.view.layer renderInContext:ctx];

    CGContextRestoreGState(ctx);
    // Save the current image context info into a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [NewGemViewController saveToAlbum:newImage meta:nil];
}

+(BOOL)canSaveToAlbum {
    // todo: toggle
    return YES;
}

+(BOOL)saveToAlbum:(UIImage *)image meta:(NSDictionary *)meta {
    // save to album
    if (![self canSaveToAlbum])
        return NO;
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [UIAlertView alertViewWithTitle:@"Cannot save to album" message:@"BabyGems could not access your camera roll. Please go to your phone Settings->Privacy to change this." cancelButtonTitle:@"Skip" otherButtonTitles:@[@"Never save"] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"camera:albumAccess:requested"];
                [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"camera:saveToAlbum"];
            }
        } onCancel:nil];
        return NO;
    }

    NSMutableDictionary *cachedMeta = [meta mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:image meta:cachedMeta toAlbum:@"BabyGems" withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Image could not be saved!");
            }
            else {
                NSLog(@"Saved to album with meta: %@", cachedMeta);
            }
        }];
    });

    return YES;
}

@end
