//
//  LoginViewController.m
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import "LoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)didClickButton:(id)sender {
    if ((UIButton *)sender == self.buttonEmail) {
        if ((UIButton *)sender == self.buttonEmail) {
            if ([self.inputUsername.text length] == 0) {
                [UIAlertView alertViewWithTitle:@"Username needed" message:@"Please enter a username"];
                return;
            }
            if ([self.inputPassword.text length] == 0) {
                [UIAlertView alertViewWithTitle:@"Password needed" message:@"Please enter a password"];
                return;
            }

            [self login];
        }
    }
    else if ((UIButton *)sender == self.buttonFacebook) {
        [self loginButtonTouchHandler:self.buttonFacebook];
    }
}

-(void)login {
    [self dismissKeyboard];

    [PFUser logInWithUsernameInBackground:self.inputUsername.text password:self.inputPassword.text block:^(PFUser *user, NSError *error) {
        if (user) {
            [_appDelegate goToMainView];
        }
        else {
            NSString *message = nil;
            if (error.code == 101) {
                message = @"Invalid username or password";
            }
            [UIAlertView alertViewWithTitle:@"Login failed" message:message];
        }
    }];
}

-(void)dismissKeyboard {
    [self.inputUsername resignFirstResponder];
    [self.inputPassword resignFirstResponder];
}

#pragma mark PFFacebookUtils
- (IBAction)loginButtonTouchHandler:(id)sender  {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {

        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [UIAlertView alertViewWithTitle:@"User not found" message:@"Click ok to sign up with your Facebook account" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] onDismiss:^(int buttonIndex) {
                    [_appDelegate goToMainView];
                } onCancel:^{
                    [user deleteInBackground];
                    [[PFFacebookUtils session] close];
                    [_appDelegate goToLoginSignup];
                }];
            } else {
                NSLog(@"User with facebook logged in!");
                [_appDelegate goToMainView];
            }
        }
    }];
}

@end
