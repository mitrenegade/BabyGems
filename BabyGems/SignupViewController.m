//
//  SignupViewController.m
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import "SignupViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FacebookHelper.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickButton:(id)sender {
    if ((UIButton *)sender == self.buttonEmail) {
        if ([self.inputUsername.text length] == 0) {
            [UIAlertView alertViewWithTitle:@"Username needed" message:@"Please enter a username"];
            return;
        }
        if ([self.inputUsername.text length] == 0) {
            [UIAlertView alertViewWithTitle:@"Password needed" message:@"Please enter a password"];
            return;
        }
        if ([self.inputConfirmation.text length] == 0) {
            [UIAlertView alertViewWithTitle:@"Confirmation needed" message:@"Please enter your password twice"];
            return;
        }
        if (![self.inputConfirmation.text isEqualToString:self.inputConfirmation.text]) {
            [UIAlertView alertViewWithTitle:@"Invalid password" message:@"Password and confirmation do not match"];
            return;
        }

        [self signup];
    }
    else if ((UIButton *)sender == self.buttonFacebook) {
        [FacebookHelper loginWithFacebookWithCompletion:^(PFUser *user) {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [_appDelegate goToMainView];
                [FacebookHelper getInfoForUser:user completion:nil];
            } else {
                NSLog(@"User with facebook logged in!");
                [UIAlertView alertViewWithTitle:@"User already exists" message:@"Click ok to log in with your Facebook account" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex) {
                    [_appDelegate goToMainView];
                } onCancel:^{
                    [[PFFacebookUtils session] close];
                    [_appDelegate goToLoginSignup];
                }];
            }
        }];
    }
}

-(void)signup {
    [self dismissKeyboard];
    PFUser *user = [PFUser user];
    user.username = self.inputUsername.text;
    user.password = self.inputPassword.text;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [_appDelegate goToMainView];
        }
        else {
            NSString *message = nil;
            if (error.code == 202) {
                message = @"Username already taken";
            }
            [UIAlertView alertViewWithTitle:@"Signup failed" message:message];
        }
    }];
}

-(void)dismissKeyboard {
    [self.inputUsername resignFirstResponder];
    [self.inputPassword resignFirstResponder];
    [self.inputConfirmation resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
