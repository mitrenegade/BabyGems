//
//  NewGemViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewGemDelegate <NSObject>

-(void)didSaveNewGem;
-(void)dismissNewGem;
@end

@class Gem;
@interface NewGemViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *quote;
    UIImage *image;

    UIImagePickerController *_picker;
    UIView *overlay;

    Gem *gem;
    BOOL imageFileReady;
    PFFile *imageFile;

    UIButton *buttonCamera;
    UIButton *buttonCancel;
    UIButton *buttonRotate;
    UIButton *buttonLibrary;
}
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *inputQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteDistanceFromBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintQuoteHeight;

-(IBAction)didClickGemBox:(id)sender;
@end
