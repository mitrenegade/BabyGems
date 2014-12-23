//
//  GemDetailCell.h
//  BabyGems
//
//  Created by Bobby Ren on 12/16/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "GemDetailProtocol.h"

@class Album;
@class Gem;
@class AsyncImageView;

@interface GemDetailCell : UICollectionViewCell <UITextViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL dragging;
    UIView *viewDragging;
    CGPoint initialTouch;
    CGRect initialFrame;

    BOOL needsObserver; // observe frame change
}

@property (nonatomic, weak) Gem *gem;
@property (weak, nonatomic) id<GemDetailDelegate> delegate;
@property (weak, nonatomic) IBOutlet AsyncImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UIView *viewQuote;
@property (weak, nonatomic) IBOutlet UILabel *labelQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteDistanceFromTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteHeight;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDateWidth;

@property (strong, nonatomic) UITextView *inputQuote;

-(IBAction)didClickShare:(id)sender;
-(IBAction)didClickTrash:(id)sender;
-(IBAction)didClickAlbum:(id)sender;
-(void)setupWithGem:(Gem *)gem;

@end
