//
//  NewGemViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewGemViewController : UIViewController <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSString *quote;
    UIImage *image;
    UIImagePickerController *picker;

    PFObject *gemObject;
    BOOL imageFileReady;
    PFFile *imageFile;
}
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCamera;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *inputQuote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintDistanceFromBottom;
@end
