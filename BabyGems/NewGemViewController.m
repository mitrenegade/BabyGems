//
//  NewGemViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 SEVEN. All rights reserved.
//

#import "NewGemViewController.h"
#import "UIImage+Resize.h"

@interface NewGemViewController ()

@end

#define PLACEHOLDER_TEXT @"Enter your gem here"

@implementation NewGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([PFUser currentUser]) {
    }
    else {
        [_appDelegate goToLoginSignup];
    }

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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [self.imageView addGestureRecognizer:tap];

    imageFileReady = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    picker = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.showsCameraControls = NO;
    }
    else
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    picker.toolbarHidden = YES; // hide toolbar of app, if there is one.
    picker.allowsEditing = YES;
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark ImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = image;
    imageFileReady = NO;
    [self enableButtons:NO];

    NSData *data = UIImageJPEGRepresentation(image, .8);
    imageFile = [PFFile fileWithData:data];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        imageFileReady = YES;
        [self enableButtons:YES];
    }];

    [self dismissViewControllerAnimated:YES completion:nil];
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Parse
-(void)saveGem {
    if (!imageFileReady)
        return;

    [self enableButtons:NO];

    if (!gemObject)
         gemObject = [PFObject objectWithClassName:@"Gem"];

    if (quote)
        [gemObject setObject:quote forKey:@"quote"];
    if (imageFile) {
        [gemObject setObject:imageFile forKey:@"image"];
    }
    [gemObject setObject:_currentUser forKey:@"user"];
    [gemObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Success %d error %@", succeeded, error);
        [self enableButtons:YES]; // todo: move to feed
    }];
}
@end
