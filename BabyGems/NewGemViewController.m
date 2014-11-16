//
//  NewGemViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 Bobby Ren. All rights reserved.
//

#import "NewGemViewController.h"
#import "UIImage+Resize.h"
#import "Gem+Parse.h"

@interface NewGemViewController ()

@end

#define PLACEHOLDER_TEXT @"Enter your gem here"

@implementation NewGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(didClickSave:)];
    self.navigationItem.rightBarButtonItem = right;
    [self enableButtons:NO];

    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* button1 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStyleBordered target:self.inputQuote action:@selector(resignFirstResponder)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* button2 = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditQuote)];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:button2, flex, button1, nil]];
    if (IS_ABOVE_IOS6) {
        [keyboardDoneButtonView setTintColor:[UIColor whiteColor]];
    }
    self.inputQuote.inputAccessoryView = keyboardDoneButtonView;
    self.inputQuote.text = PLACEHOLDER_TEXT;

    imageFileReady = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.imageView addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)enableButtons:(BOOL)enabled {
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

-(void)didClickSave:(id)sender {
    [self saveGem];
}

#pragma mark Textview delegate
-(void)cancelEditQuote {
    self.inputQuote.text = quote;
    if ([self.inputQuote.text length] == 0) {
        [self.inputQuote setText:PLACEHOLDER_TEXT];
        quote = @"";
    }
    [self.inputQuote resignFirstResponder];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self.inputQuote setText:quote];
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self.inputQuote resignFirstResponder];
    if ([self.inputQuote.text length] == 0 || [self.inputQuote.text isEqualToString:PLACEHOLDER_TEXT]) {
        [self.inputQuote setText:PLACEHOLDER_TEXT];
        quote = @"";
    }
    else {
        quote = self.inputQuote.text;
    }
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.inputQuote resignFirstResponder];
    if (quote.length) {
        [self enableButtons:YES];
    }
    else {
        [self enableButtons:NO];
    }
}

#pragma mark Camera
-(void)handleGesture:(UIGestureRecognizer *)gesture {
    NSLog(@"Take a photo!");
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

    [self.navigationController presentViewController:_picker animated:YES completion:nil];
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

    buttonLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLibrary setFrame:CGRectMake(0, 0, 30, 30)];
    [buttonLibrary setImage:[UIImage imageNamed:@"polaroid"] forState:UIControlStateNormal];
    [buttonLibrary setTintColor:[UIColor whiteColor]];
    [buttonLibrary setCenter:CGPointMake(260, frame.size.height - bottom.frame.size.height / 2)];
    [buttonLibrary addTarget:self action:@selector(showLibrary) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:buttonLibrary];

    [_picker setCameraOverlayView:overlay];
}


#pragma mark ImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)_picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    imageFileReady = NO;
    [self enableButtons:NO];

    if (!gem) {
        gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
    }

    // allow offline image storage
    NSData *data = UIImageJPEGRepresentation(image, .8);
    gem.offlineImage = data;

    // online image storage
    imageFile = [PFFile fileWithData:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        imageFileReady = YES;
        [self enableButtons:YES];
    }];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_picker.presentedViewController) {
        [_picker dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark Parse
-(void)saveGem {
    [self enableButtons:NO];

    if (!gem) {
        gem = (Gem *)[Gem createEntityInContext:_appDelegate.managedObjectContext];
    }

    gem.quote = quote;
    if (imageFileReady) {
        gem.imageURL = [imageFile url];

        // also add a pointer to the PFFile if possible
        if (gem.pfObject)
            [gem.pfObject setObject:imageFile forKey:@"imageFile"];
    }
    else {
        // todo: set a flag to do image upload later when internet is ready
    }

    [gem saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d", success);
        [self enableButtons:YES];
    }];

    // offline storage
    [_appDelegate.managedObjectContext performBlockAndWait:^{
        [_appDelegate.managedObjectContext save:nil];
    }];

    [self.delegate didSaveNewGem];
}

- (void)keyboardWillShow:(NSNotification *)n
{
    CGSize keyboardSize = [[n.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.constraintDistanceFromBottom.constant = keyboardSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHide:(NSNotification *)n {
    self.constraintDistanceFromBottom.constant = 40;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:.3 animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark Navigation
-(void)didClickGemBox:(id)sender {
    [self.delegate dismissNewGem];
}

@end
