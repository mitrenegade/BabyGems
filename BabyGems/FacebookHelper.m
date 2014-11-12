//
//  FacebookHelper.m
//  BabyGems
//
//  Created by Bobby Ren on 11/12/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "FacebookHelper.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation FacebookHelper

#pragma mark PFFacebookUtils
+(void)loginWithFacebookWithCompletion:(void(^)(PFUser *user)) completion {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me"];

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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (completion) {
                completion(user);
            }
        }
    }];
}
@end
