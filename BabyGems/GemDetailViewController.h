//
//  GemDetailViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/27/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "AlbumsViewController.h"

@class Album;
@class Gem;
@class AsyncImageView;

@protocol GemDetailDelegate <NSObject>

-(void)didMoveGem:(Gem *)gem toAlbum:(Album *)album;

@end

@interface GemDetailViewController : UIViewController <UITextViewDelegate, AlbumsViewDelegate>

@property (nonatomic, weak) Gem *gem;
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet AsyncImageView *imageView;
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
@end
