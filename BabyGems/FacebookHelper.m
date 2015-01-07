//
//  FacebookHelper.m
//  BabyGems
//
//  Created by Bobby Ren on 11/12/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "FacebookHelper.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

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

+(void)getInfoForUser:(PFUser *)user completion:(void(^)(NSDictionary *results, NSError *error)) completion {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if (completion)
                completion(nil, error);
        }
        else {
            NSLog(@"Results: %@", result);
            NSString *fullName = result[@"name"];
            if (fullName) {
                user[@"name"] = fullName;
            }

            NSString *firstName = result[@"first_name"];
            if (firstName) {
                user[@"firstName"] = firstName;
            }

            NSString *lastName = result[@"last_name"];
            if (lastName) {
                user[@"lastName"] = lastName;
            }

            NSString *email = result[@"email"];
            if (email) {
                user.email = email;
            }

            [self updateCanonicalInfoForUser:user fullName:fullName firstName:firstName lastName:lastName email:email];

            if (completion)
                completion(result, error);
        }
    }];
}

+(void)updateCanonicalInfoForUser:(PFUser *)user fullName:(NSString *)fullName firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email {
    NSString *canonicalFullName = @"";
    if (fullName)
        canonicalFullName = [NSString stringWithFormat:@"%@%@ ", canonicalFullName, [fullName lowercaseString]];
    if (firstName && ![canonicalFullName containsString:[firstName lowercaseString]])
        canonicalFullName = [NSString stringWithFormat:@"%@%@ ", canonicalFullName, [firstName lowercaseString]];
    if (lastName && ![canonicalFullName containsString:[lastName lowercaseString]])
        canonicalFullName = [NSString stringWithFormat:@"%@%@ ", canonicalFullName, [lastName lowercaseString]];
    if (email) {
        NSInteger index = [email rangeOfString:@"@"].location;
        if (index != NSNotFound) {
            NSString *substring = [email substringToIndex:index];
            canonicalFullName = [NSString stringWithFormat:@"%@%@ ", canonicalFullName, [substring lowercaseString]];
        }
    }

    // stored for search purposes
    user[@"canonicalFullName"] = canonicalFullName;
    user[@"canonicalEmail"] = [email lowercaseString];

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"User info updated from Facebook");
        }
    }];

}
@end
