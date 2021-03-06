//
//  CameraViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/26/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ELCImagePickerController.h>
@protocol CameraDelegate <NSObject>

-(void)didTakePicture:(UIImage *)image meta:(NSDictionary *)meta;
-(void)didTakeMultiplePictures:(NSArray *)images meta:(NSArray *)meta;
@end

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, ELCImagePickerControllerDelegate>
{
    UIImagePickerController *_picker;
    ELCImagePickerController *_multiPicker;

    UIView *overlay;

    UIButton *buttonCamera;
    UIButton *buttonCancel;
    UIButton *buttonRotate;
    UIButton *buttonLibrary;
}

@property (weak, nonatomic) id delegate;

-(void)showCameraFromController:(UIViewController *)controller;
-(void)showLibraryFromController:(UIViewController *)controller;
@end
