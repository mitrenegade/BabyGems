//
//  NewGemViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@protocol NewGemDelegate <NSObject>

-(void)didSaveNewGem;
-(void)dismissNewGem;
@end

@class Gem;
@interface NewGemViewController : UIViewController <UITextViewDelegate, CameraDelegate>
{
    Gem *gem;
    BOOL imageFileReady;
    PFFile *imageFile;

    CameraViewController *cameraController;
}
@property (weak, nonatomic) id delegate;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSString *quote;
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *inputQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteHeight;

-(IBAction)didClickGemBox:(id)sender;
-(void)saveGemWithQuote:(NSString *)quote image:(UIImage *)image;
@end
