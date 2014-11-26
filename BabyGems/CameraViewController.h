//
//  CameraViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/26/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraDelegate <NSObject>

-(void)didTakePicture:(UIImage *)image;

@end

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIImagePickerController *_picker;

    UIView *overlay;

    UIButton *buttonCamera;
    UIButton *buttonCancel;
    UIButton *buttonRotate;
    UIButton *buttonLibrary;
}

@property (weak, nonatomic) id delegate;

-(void)showCameraFromController:(UIViewController *)controller;
@end
