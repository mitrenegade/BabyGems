//
//  NewGemViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@class Gem;
@class Album;

@protocol NewGemDelegate <NSObject>

-(Album *)currentAlbum;
-(void)didSaveNewGem;
-(void)dismissNewGem;
@end

@interface NewGemViewController : UIViewController <UITextViewDelegate>
{
    Gem *gem;
    BOOL imageFileReady;
    PFFile *imageFile;

    BOOL dragging;
    UIView *viewDragging;
    CGPoint initialTouch;
    CGRect initialFrame;

}
@property (weak, nonatomic) id delegate;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSDictionary *meta;
@property (nonatomic) NSString *quote;
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCamera;

@property (weak, nonatomic) IBOutlet UIView *viewCanvas;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *textCanvas;
@property (weak, nonatomic) IBOutlet UITextView *inputQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteHeight;

-(IBAction)didClickGemBox:(id)sender;
-(void)saveGemWithQuote:(NSString *)quote image:(UIImage *)image album:(Album *)album;

+(BOOL)toggleSaveToAlbum;
@end
