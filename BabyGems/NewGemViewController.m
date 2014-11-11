//
//  NewGemViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 SEVEN. All rights reserved.
//

#import "NewGemViewController.h"

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

-(void)enableButtons:(BOOL)enabled {
    [self.navigationItem.rightBarButtonItem setEnabled:enabled];
}

-(void)didClickSave:(id)sender {

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

@end
