//
//  CameraViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/26/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "CameraViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ELCImagePickerController.h>

@interface CameraViewController ()

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)showLibraryFromController:(UIViewController *)controller {
#if 0
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    _picker.allowsEditing = NO;
    _picker.delegate = self;

    CGRect frame = _appDelegate.window.bounds;
    frame.origin.y = 0;
    [self addOverlayWithFrame:frame];

    [controller.navigationController presentViewController:_picker animated:YES completion:nil];
#else
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
    elcPicker.maximumImagesCount = 4; //Set the maximum number of images to select, defaults to 4
    elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
    elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
    elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
    elcPicker.imagePickerDelegate = self;

    _multiPicker = elcPicker;

    //Present modally
    [controller.navigationController presentViewController:elcPicker animated:YES completion:nil];

#endif
}

-(void)showCameraFromController:(UIViewController *)controller {
    _picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.showsCameraControls = NO;
    }
    else
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    _picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    _picker.allowsEditing = NO;
    _picker.delegate = self;

    CGRect frame = _appDelegate.window.bounds;
    frame.origin.y = 0;
    [self addOverlayWithFrame:frame];

    [controller.navigationController presentViewController:_picker animated:YES completion:nil];
}

-(void)addOverlayWithFrame:(CGRect)frame {
    // Initialization code

    if (_picker.sourceType != UIImagePickerControllerSourceTypeCamera)
        return;

    overlay = [[UIView alloc] initWithFrame:frame];

    CALayer *top = [[CALayer alloc] init];
    top.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
    top.backgroundColor = [[UIColor blackColor] CGColor];
    CALayer *bottom = [[CALayer alloc] init];
    bottom.frame = CGRectMake(0, frame.size.height - 80, frame.size.width, 80);
    bottom.backgroundColor = [[UIColor blackColor] CGColor];

    [overlay.layer addSublayer:top];
    [overlay.layer addSublayer:bottom];

    buttonCamera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 72)];
    [buttonCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [buttonCamera setContentMode:UIViewContentModeCenter];
    [buttonCamera setBackgroundColor:[UIColor clearColor]];
    [buttonCamera setCenter:CGPointMake(160, frame.size.height - bottom.frame.size.height / 2)];
    [buttonCamera addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:buttonCamera];

    buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonCancel setFrame:CGRectMake(0, 0, 30, 30)];
    [buttonCancel setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
    [buttonCancel setTintColor:[UIColor whiteColor]];
    [buttonCancel setCenter:CGPointMake(30, top.frame.size.height/2)];
    [buttonCancel addTarget:self action:@selector(dismissCamera) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:buttonCancel];

    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        buttonRotate = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonRotate setFrame:CGRectMake(0, 0, 40, 40)];
        [buttonRotate setBackgroundColor:[UIColor clearColor]];
        [buttonRotate setCenter:CGPointMake(top.frame.size.width - 30, top.frame.size.height/2)];
        [buttonRotate setImage:[UIImage imageNamed:@"rotateCamera"] forState:UIControlStateNormal];
        [buttonRotate addTarget:self action:@selector(rotateCamera) forControlEvents:UIControlEventTouchUpInside];
        [overlay addSubview:buttonRotate];
    }

    /*
    buttonLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLibrary setFrame:CGRectMake(0, 0, 30, 30)];
    [buttonLibrary setImage:[UIImage imageNamed:@"polaroid"] forState:UIControlStateNormal];
    [buttonLibrary setTintColor:[UIColor whiteColor]];
    [buttonLibrary setCenter:CGPointMake(260, frame.size.height - bottom.frame.size.height / 2)];
    [buttonLibrary addTarget:self action:@selector(showLibrary) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:buttonLibrary];
     */
    [_picker setCameraOverlayView:overlay];
}


#pragma mark ImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [CameraViewController getMetaForInfo:info withCompletion:^(NSDictionary *meta) {
        NSLog(@"Meta: %@", meta);
        // for now, no active stripping of metadata is done. When we save the image to parse, the metadata is not saved anyways.
        [self.delegate didTakePicture:image meta:meta];
    }];
}

+(void)getMetaForInfo:(NSDictionary *)info withCompletion:(void(^)(NSDictionary *meta))completion {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage] || [mediaType isEqualToString:ALAssetTypePhoto]) {
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        if (url) {
            ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
            [assetsLib assetForURL:url resultBlock:^(ALAsset *asset) {
                if (completion)
                    completion([[asset defaultRepresentation] metadata]);
            } failureBlock:^(NSError *error) {
                if (completion)
                    completion(nil);
            }];
        }
        else {
            if (completion)
                completion([info objectForKey:UIImagePickerControllerMediaMetadata]);
        }
    }
    else {
        if (completion)
            completion(nil);
    }
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_picker.presentedViewController) {
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissCamera];
    }
}

-(void)takePicture {
    [_picker takePicture];
}

-(void)showLibrary {
    UIImagePickerController *library = [[UIImagePickerController alloc] init];
    library.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    library.toolbarHidden = YES; // hide toolbar of app, if there is one.
    library.delegate = self;

    [_picker presentViewController:library animated:YES completion:nil];
}

-(void)rotateCamera {
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        return;
    }

    if(_picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
    {
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    else {
        _picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
}

-(void)dismissCamera {
    if ([self.delegate respondsToSelector:@selector(dismissCamera)])
        [self.delegate dismissCamera];
    else
        [_picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark elcimagepickerDelegate
-(void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSLog(@"Finished: %@", info);

    NSMutableArray *imageArray = [NSMutableArray array];
    NSMutableArray *metaArray = [NSMutableArray array];
    __block BOOL failed = NO;
    for (NSDictionary *assetInfo in info) {
        UIImage *image = [assetInfo objectForKey:UIImagePickerControllerOriginalImage];
        [CameraViewController getMetaForInfo:assetInfo withCompletion:^(NSDictionary *meta) {
            NSLog(@"Meta: %@", meta);
            if (meta) {
                // for now, no active stripping of metadata is done. When we save the image to parse, the metadata is not saved anyways.
                [imageArray addObject:image];
                [metaArray addObject:meta];

                if (imageArray.count == info.count) {
                    [self.delegate didTakeMultiplePictures:imageArray meta:metaArray];
                }
            }
            else {
                if (!failed) {
                    [UIAlertView alertViewWithTitle:@"Invalid image" message:@"One or more selected files cannot be uploaded. Please only select photos."];
                    failed = YES;
                }
            }
        }];
    }
}

-(void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    NSLog(@"Cancelled");
    [_multiPicker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    NSLog(@"Here");
}

@end
