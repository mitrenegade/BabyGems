//
//  Notification+Parse.m
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "Notification+Parse.h"

@implementation Notification (Parse)

-(void)updateFromParseWithCompletion:(void (^)(BOOL))completion {
    // refreshes object from parse
    [super updateFromParseWithCompletion:^(BOOL success) {
        if (success) {
            [self updateAttributesFromPFObject];
        }
        if (completion)
            completion(success);
    }];
}

-(void)updateAttributesFromPFObject {
    self.message = [self.pfObject objectForKey:@"message"];
    self.seen = [self.pfObject objectForKey:@"seen"];
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    [super saveOrUpdateToParseWithCompletion:^(BOOL success) {

        if (self.message)
            self.pfObject[@"message"] = self.message;
        if (self.seen)
            self.pfObject[@"seen"] = self.seen;

        if (_currentUser) {
            self.pfObject[@"user"] = _currentUser;
            self.pfObject[@"pfUserID"] = _currentUser.objectId;
        }

        [self.pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // always update from parse in case web made changes on beforeSave or afterSave
                // doesn't make an extra web request
                self.parseID = self.pfObject.objectId;
                [self updateFromParseWithCompletion:^(BOOL success) {
                    if (completion)
                        completion(succeeded);
                }];
            }
            else {
                if (completion)
                    completion(succeeded);
            }
        }];
    }];
}

@end
