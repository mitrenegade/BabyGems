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
#import "BackgroundHelper.h"

@interface NewGemViewController ()

@end

@implementation NewGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(didClickSave:)];
    self.navigationItem.rightBarButtonItem = right;
    //[self enableButtons:NO];

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

    if (self.image)
        [self updateGemImage];
    if (self.quote.length)
        self.inputQuote.text = self.quote;

    [self updateTextSize];

    // gestures
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.viewBG addGestureRecognizer:pan];

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self  action:@selector(handlePinch:)];
    [self.viewBG addGestureRecognizer:pinch];
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

-(void)updateGemImage {
    if (!self.image)
        return;
    self.imageView.image = self.image;
}

#pragma mark Parse
-(void)saveGem {
    if (self.image) {
        NSNumber *permission = [[NSUserDefaults standardUserDefaults] valueForKey:@"camera:saveToAlbum"];
        if (!permission) {
            [UIAlertView alertViewWithTitle:@"Save images to camera roll?" message:@"Would you like babyGems to store pictures you take to the camera roll?" cancelButtonTitle:@"No thanks" otherButtonTitles:@[@"Yes"] onDismiss:^(int buttonIndex) {
                [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"camera:saveToAlbum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self saveGem];
            } onCancel:^{
                [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:@"camera:saveToAlbum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self saveGem];
            }];
            return;
        }
    }

    [self saveGemWithQuote:self.quote image:self.image album:[self.delegate currentAlbum]];
}

-(void)saveGemWithQuote:(NSString *)quote image:(UIImage *)image album:(Album *)album {
    [self enableButtons:NO];

    if (!gem) {
        gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
    }
    gem.quote = quote;
    gem.createdAt = [NSDate date];

    // allow offline image storage
    NSData *data = UIImageJPEGRepresentation(self.image, .8);
    gem.offlineImage = data;
    gem.album = album;

    [BackgroundHelper keepTaskInBackgroundForPhotoUpload];
    [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d", success);
        [self enableButtons:YES];
        [self notify:@"gems:updated"];

        // online image storage
        imageFile = [PFFile fileWithData:data];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [gem.pfObject setObject:imageFile forKey:@"imageFile"];
            gem.imageURL = imageFile.url;
            [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
                [self notify:@"gems:updated"];
                [BackgroundHelper stopTaskInBackgroundForPhotoUpload];
            }];
        }];

        [self.delegate didSaveNewGem];
    }];

    // offline storage
    [_appDelegate.managedObjectContext save:nil];

    if (self.image && [NewGemViewController canSaveToAlbum]) {
        [NewGemViewController saveToAlbum:image meta:self.meta];
    }
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
    if ([self.quote length] == 0)
        [self.inputQuote setHidden:YES];

    CGSize size = self.view.frame.size;
    UIGraphicsBeginImageContext(size);

    // Put everything in the current view into the screenshot
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    [self.view.layer renderInContext:ctx];

    CGContextRestoreGState(ctx);
    // Save the current image context info into a UIImage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [NewGemViewController saveToAlbum:newImage meta:nil];
}

+(BOOL)canSaveToAlbum {
    NSNumber *permission = [[NSUserDefaults standardUserDefaults] valueForKey:@"camera:saveToAlbum"];
    return [permission boolValue];
}

+(void)toggleSaveToAlbum {
    [[NSUserDefaults standardUserDefaults] setValue:@(![self canSaveToAlbum]) forKey:@"camera:saveToAlbum"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if ([self canSaveToAlbum]) {
        [UIAlertView alertViewWithTitle:@"Camera roll enabled" message:@"babyGems will save pictures you take to the camera roll."];
    }
    else {
        [UIAlertView alertViewWithTitle:@"Camera roll disabled" message:@"babyGems will no longer save pictures you take to the camera roll."];
    }
}

+(BOOL)saveToAlbum:(UIImage *)image meta:(NSDictionary *)meta {
    // save to album
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
        [UIAlertView alertViewWithTitle:@"Cannot save to camera roll" message:@"babyGems could not access your camera roll. (Your gem was successfully saved to your gemBox.) You can go to Settings->Privacy to change this." cancelButtonTitle:@"Skip" otherButtonTitles:@[@"Never save to camera roll"] onDismiss:^(int buttonIndex) {
            if (buttonIndex == 0) {
                [self toggleSaveToAlbum];
            }
        } onCancel:nil];
        return NO;
    }

    NSMutableDictionary *cachedMeta = [meta mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[ALAssetsLibrary sharedALAssetsLibrary] saveImage:image meta:cachedMeta toAlbum:@"babyGems" withCompletionBlock:^(NSError *error) {
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

#pragma mark gestures
#pragma mark Gesture recognizers
-(void)handlePan:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!dragging) {
                [self.inputQuote resignFirstResponder];
                dragging = YES;
                CGPoint point = [gesture locationInView:self.viewBG];
                initialTouch = point;
                if (CGRectContainsPoint(self.textCanvas.frame, point)) {
                    viewDragging = self.textCanvas;
                    initialFrame = viewDragging.frame;

                    [self.inputQuote resignFirstResponder];
                }
                else if (CGRectContainsPoint(self.viewCanvas.frame, point)) {
                    point = [gesture locationInView:self.viewCanvas];
                    viewDragging = self.imageView;
                    initialFrame = viewDragging.frame;
                }
                else {
                    dragging = NO;
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            if (dragging) {
                // update frame of viewDragging
                if (viewDragging == self.textCanvas) {
                    // change both x and y position
                    CGPoint point = [gesture locationInView:self.viewBG];
                    int dx = point.x - initialTouch.x;
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.x += dx;
                    frame.origin.y += dy;

                    if (frame.origin.x >= self.viewCanvas.frame.size.width - self.textCanvas.frame.size.width)
                        frame.origin.x = self.viewCanvas.frame.size.width - self.textCanvas.frame.size.width;
                    if (frame.origin.x <= 0)
                        frame.origin.x = 0;
                    if (frame.origin.y >= self.viewCanvas.frame.size.height - self.textCanvas.frame.size.height)
                        frame.origin.y = self.viewCanvas.frame.size.height - self.textCanvas.frame.size.height;
                    if (frame.origin.y <= 0)
                        frame.origin.y = 0;
                    viewDragging.frame = frame;
                }
                else if (viewDragging == self.imageView) {
                    CGPoint point = [gesture locationInView:self.viewBG];
                    // change x and y
                    int dx = point.x - initialTouch.x;
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.y += dy;
                    frame.origin.x += dx;
                    NSLog(@"New frame: %f %f %f %f imageSize %f %f", frame.origin.x, frame.origin.y, frame.origin.x + frame.size.width, frame.origin.y + frame.size.height, self.image.size.width, self.image.size.height);
                    if (frame.origin.x > 0)
                        frame.origin.x = 0;
                    if (frame.origin.x + frame.size.width < self.viewCanvas.frame.size.width)
                        frame.origin.x = self.viewCanvas.frame.size.width - frame.size.width;
                    if (frame.origin.y > 0)
                        frame.origin.y = 0;
                    if (frame.origin.y + frame.size.height < self.viewCanvas.frame.size.height)
                        frame.origin.y = self.viewCanvas.frame.size.height - frame.size.height;
                    viewDragging.frame = frame;
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            if (dragging) {
                dragging = NO;
                viewDragging = nil;
            }
        }
    }
}

-(void)handlePinch:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gesture;
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            [self.inputQuote resignFirstResponder];
            initialFrame = self.imageView.frame;
            NSLog(@"Initial: %f %f %f %f", initialFrame.origin.x, initialFrame.origin.y, initialFrame.size.width, initialFrame.size.height);
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            float scale = pinch.scale;
            NSLog(@"Scale: %f", scale);
            CGRect frame;
            frame.size.width = initialFrame.size.width * scale;
            frame.size.height = initialFrame.size.height * scale;
            frame.origin.x = initialFrame.origin.x + initialFrame.size.width / 2 - frame.size.width / 2;
            frame.origin.y = initialFrame.origin.y + initialFrame.size.height / 2 - frame.size.height / 2;

            self.imageView.frame = frame;
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            CGRect frame = self.imageView.frame;
            if (frame.origin.x > 0)
                frame.origin.x = 0;
            if (frame.origin.y > 0)
                frame.origin.y = 0;
            if (frame.size.width < self.viewBG.frame.size.width) {
                frame.size.width = self.viewBG.frame.size.width;
                frame.size.height = frame.size.width / self.image.size.width * self.image.size.height;
            }
            if (frame.size.height < self.viewBG.frame.size.height)
                frame.size.height = self.viewBG.frame.size.height;
            if (frame.origin.x + frame.size.width < self.viewBG.frame.size.width)
                frame.origin.x = self.viewBG.frame.size.width - frame.size.width;
            if (frame.origin.y + frame.size.height < self.viewBG.frame.size.height)
                frame.origin.y = self.viewBG.frame.size.height - frame.size.height;
            self.imageView.frame = frame;
        }
    }
}

@end
