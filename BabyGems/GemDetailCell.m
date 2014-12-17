//
//  GemDetailCell.m
//  BabyGems
//
//  Created by Bobby Ren on 12/16/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemDetailCell.h"
#import "Gem.h"
#import <AsyncImageView/AsyncImageView.h>
#import "Gem+Parse.h"
#import "Util.h"
#import "AlbumsViewController.h"

@implementation GemDetailCell

-(void)setupWithGem:(Gem *)gem {
    self.gem = gem;
    if (self.gem) {
        if (self.gem.quote.length) {
            self.labelQuote.text = [NSString stringWithFormat:@"“%@”", self.gem.quote];
        }
        else {
            self.labelQuote.text = PLACEHOLDER_TEXT;
        }

        NSString *text = self.gem.quote;
        UIFont *font = CHALK(16);
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        self.constraintQuoteHeight.constant = rect.size.height + 40;
        self.constraintQuoteDistanceFromTop.priority = 900;
        self.constraintQuoteHeight.priority = 1000;
        NSData *data = self.gem.offlineImage;
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
            [self setupImageBorder];
        }
        else if (self.gem.imageURL) {
            self.imageView.imageURL = [NSURL URLWithString:self.gem.imageURL];
            [self setupImageBorder];
        }
        else {
            // only text/quote, no image
            self.imageView.image = nil;
            self.labelQuote.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
            self.labelQuote.textColor = [UIColor darkGrayColor];
            self.constraintQuoteDistanceFromTop.constant = 0;
            self.constraintQuoteDistanceFromBottom.constant = 0;
            self.constraintQuoteDistanceFromTop.priority = 1000;
            self.constraintQuoteHeight.priority = 900;
            [self setupTextBorder];
        }

        self.labelDate.text = [Util timeAgo:self.gem.createdAt];
        rect = [self.labelDate.text boundingRectWithSize:self.labelDate.superview.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelDate.font} context:nil];
        self.constraintDateWidth.constant = rect.size.width + 20;
    }

    // input
    self.inputQuote = [[UITextView alloc] init];
    self.inputQuote.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, 150);
    self.inputQuote.backgroundColor = [UIColor lightGrayColor];
    self.inputQuote.font = CHALK(14);
    self.inputQuote.textColor = [UIColor whiteColor];
    self.inputQuote.textAlignment = NSTextAlignmentCenter;
    self.inputQuote.delegate = self;
    [self addSubview:self.inputQuote];

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    if (IS_ABOVE_IOS6)
        keyboardDoneButtonView.tintColor = [UIColor whiteColor];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(closeKeyboardInput:)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(updateQuote:)];
    [keyboardDoneButtonView setItems:@[cancel, done]];
    self.inputQuote.inputAccessoryView = keyboardDoneButtonView;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self addGestureRecognizer:tap];

    [self listenFor:UIKeyboardWillShowNotification action:@selector(keyboardWillShow:)];
    [self listenFor:UIKeyboardWillHideNotification action:@selector(keyboardWillHide:)];
}

-(void)setupImageBorder {
    self.imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if (_appDelegate.borderStyle == BorderStyleRound) {
        self.imageView.layer.borderWidth = 1;
        self.imageView.layer.cornerRadius = 5;
    }
    else {
        self.imageView.layer.borderWidth = 0;
        self.imageView.layer.cornerRadius = 0;
    }
}

-(void)setupTextBorder {
    self.labelQuote.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if (_appDelegate.borderStyle == BorderStyleRound) {
        self.labelQuote.layer.borderWidth = 1;
        self.labelQuote.layer.cornerRadius = 5;
    }
    else {
        self.labelQuote.layer.borderWidth = 0;
        self.labelQuote.layer.cornerRadius = 0;
    }
}

-(IBAction)didClickShare:(id)sender {
    [self.delegate shareGem:self.gem];
}

-(IBAction)didClickTrash:(id)sender {
    [UIAlertView alertViewWithTitle:@"Delete gem?" message:@"Are you sure you want to permanently delete this gem?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Delete Gem"] onDismiss:^(int buttonIndex) {
        [self.gem.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [_appDelegate.managedObjectContext deleteObject:self.gem];
                [self.delegate didDeleteGem:self.gem];
                [self notify:@"gems:updated"];
            }
            else {
                NSLog(@"Failed!");
                [UIAlertView alertViewWithTitle:@"Error" message:@"Could not delete gem, please try again"];
            }
        }];
    } onCancel:nil];
}

#pragma mark input
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
        CGPoint touch = [gesture locationInView:self];
        if (CGRectContainsPoint(self.viewQuote.frame, touch)) {
            [self updateInputWithText:self.gem.quote.length?self.gem.quote:@""];
            [self.inputQuote becomeFirstResponder];
        }
    }
}

-(void)updateQuote:(id)sender {
    // remove leading whitespace
    NSString *text = [self.inputQuote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.gem.quote = text;
    self.labelQuote.text = self.gem.quote.length?[NSString stringWithFormat:@"“%@”", self.gem.quote]:nil;
    [self notify:@"gems:updated" object:nil userInfo:nil];

    [self closeKeyboardInput:nil];
    __block NSString *expected = text;
    [self.gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success: %d quote %@", success, self.gem.quote);
        if (!success || ![self.gem.quote isEqualToString:expected]) {
            [UIAlertView alertViewWithTitle:@"Update failed" message:@"Your gem could not be updated. Please try again!"];
            self.labelQuote.text = self.gem.quote.length?[NSString stringWithFormat:@"“%@”", self.gem.quote]:nil;
            [self notify:@"gems:updated" object:nil userInfo:nil];
        }
        [_appDelegate saveContext];
    }];
}

-(void)closeKeyboardInput:(id)sender {
    [self.inputQuote resignFirstResponder];
}

-(void)keyboardWillShow:(NSNotification *)n {
    CGSize keyboardSize = [[n.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    float y =  (self.frame.size.height - keyboardSize.height - self.inputQuote.frame.size.height);

    CGRect viewFrame = self.inputQuote.frame;
    viewFrame.origin.y = y;

    [UIView animateWithDuration:.3 animations:^{
        [self.inputQuote setFrame:viewFrame];
    } completion:^(BOOL finished) {
    }];
}

-(void)keyboardWillHide:(NSNotification *)n {
    CGRect viewFrame = self.inputQuote.frame;
    viewFrame.origin.y = self.frame.size.height;
    [UIView animateWithDuration:.3 animations:^{
        self.inputQuote.frame = viewFrame;
    } completion:nil];
}

-(void)updateInputWithText:(NSString *)text {
    UIFont *font = self.inputQuote.font;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(self.inputQuote.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    CGRect viewFrame = self.inputQuote.frame;
    viewFrame.size.height = rect.size.height + 40;
    self.inputQuote.frame = viewFrame;
    self.inputQuote.text = text;
}

#pragma mark TextViewDelegate
-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.inputQuote resignFirstResponder];
    return YES;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"GemDetailToAlbums"]) {
        AlbumsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.currentAlbum = self.gem.album;
        controller.mode = AlbumsViewModeSelect;
    }
}
 */

#pragma mark AlbumsViewDelegate
-(void)didSelectAlbum:(Album *)album {
    self.gem.album = album;
//    [self.navigationController popViewControllerAnimated:YES];
    [self.gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Gem saved!");

        [self.delegate didMoveGem:self.gem toAlbum:album];
    }];
}

@end
