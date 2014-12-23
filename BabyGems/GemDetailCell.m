//
//  GemDetailCell.m
//  BabyGems
//
//  Created by Bobby Ren on 12/16/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemDetailCell.h"
#import "Gem+Info.h"
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
        self.constraintQuoteHeight.priority = 999;

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
            self.constraintQuoteDistanceFromTop.priority = 999;
            self.constraintQuoteHeight.priority = 900;
            [self setupTextBorder];
        }

        self.labelDate.text = [Util timeAgo:self.gem.createdAt];
        rect = [self.labelDate.text boundingRectWithSize:self.labelDate.superview.frame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.labelDate.font} context:nil];
        self.constraintDateWidth.constant = rect.size.width + 20;
    }

    self.imageView.crossfadeDuration = 0;

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

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    pan.delegate = self;
    [self.viewBG addGestureRecognizer:pan];

    [self listenFor:UIKeyboardWillShowNotification action:@selector(keyboardWillShow:)];
    [self listenFor:UIKeyboardWillHideNotification action:@selector(keyboardWillHide:)];

    [self.viewBG addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Change: %@ keypath: %@", keyPath, change);

    if ([keyPath isEqualToString:@"bounds"] && [self.gem.textPositionByPercent floatValue] > 0) {
        // percent is 0 - 1, indicates the ratio of self.constraintQuoteHeight to the detailview's height
        float height = self.viewBG.frame.size.height;
        float offset = height * self.gem.textPositionByPercent.floatValue;
        self.constraintQuoteDistanceFromTop.priority = 998;
        self.constraintQuoteDistanceFromBottom.priority = 997;
        self.constraintQuoteDistanceFromTop.constant = offset;
    }
}

-(void)dealloc {
    [self.viewBG removeObserver:self forKeyPath:@"bounds"];
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

#pragma mark cell buttons
-(IBAction)didClickShare:(id)sender {
    UIImage *image = self.imageView.image;
    if (!image) {
        if (self.gem.offlineImage)
            image = [UIImage imageWithData:self.gem.offlineImage];
    }
    [self.delegate shareGem:self.gem image:image];
}

-(IBAction)didClickTrash:(id)sender {
    [UIAlertView alertViewWithTitle:@"Delete gem?" message:@"Are you sure you want to permanently delete this gem?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Delete Gem"] onDismiss:^(int buttonIndex) {
        [self.delegate deleteGem:self.gem];
    } onCancel:nil];
}

-(IBAction)didClickAlbum:(id)sender {
    [self.delegate showAlbumSelectorForGem:self.gem];
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
    else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        if ([gesture state] == UIGestureRecognizerStateBegan) {
            if (!dragging) {
                [self.inputQuote resignFirstResponder];
                dragging = YES;
                CGPoint point = [gesture locationInView:self.viewBG];
                initialTouch = point;
                if (CGRectContainsPoint(self.viewQuote.frame, point)) {
                    viewDragging = self.viewQuote;
                    initialFrame = viewDragging.frame;

                    [self.inputQuote resignFirstResponder];
                }
                else {
                    dragging = NO;
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateChanged) {
            if (dragging) {
                // update frame of viewDragging
                if (viewDragging == self.viewQuote) {
                    // change both x and y position
                    CGPoint point = [gesture locationInView:self.viewBG];
                    int dx = point.x - initialTouch.x;
                    int dy = point.y - initialTouch.y;
                    CGRect frame = initialFrame;
                    frame.origin.x += dx;
                    frame.origin.y += dy;

                    if (frame.origin.x >= self.viewBG.frame.size.width - self.viewQuote.frame.size.width)
                        frame.origin.x = self.viewBG.frame.size.width - self.viewQuote.frame.size.width;
                    if (frame.origin.x <= 0)
                        frame.origin.x = 0;
                    if (frame.origin.y >= self.viewBG.frame.size.height - self.viewQuote.frame.size.height - QUOTE_INSET_FROM_BOTTOM)
                        frame.origin.y = self.viewBG.frame.size.height - self.viewQuote.frame.size.height - QUOTE_INSET_FROM_BOTTOM;
                    if (frame.origin.y <= QUOTE_INSET_FROM_TOP)
                        frame.origin.y = QUOTE_INSET_FROM_TOP;
                    viewDragging.frame = frame;
                }
            }
        }
        else if ([gesture state] == UIGestureRecognizerStateEnded) {
            if (dragging) {
                dragging = NO;
                if (viewDragging == self.viewQuote) {
                    [self.gem updateTextPosition:self.viewQuote.frame.origin inFrame:self.viewBG.frame];
                    [self.gem saveOrUpdateToParseWithCompletion:nil];
                }
                viewDragging = nil;
            }
        }
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.viewQuote.frame, point) && (self.gem.imageURL || self.gem.offlineImage)) {
        return YES;
    }
    return NO;
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
@end
