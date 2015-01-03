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
    self.toUserID = [self.pfObject objectForKey:@"toUserID"];
    self.itemID = [self.pfObject objectForKey:@"itemID"];
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    [super saveOrUpdateToParseWithCompletion:^(BOOL success) {

        if (self.message)
            self.pfObject[@"message"] = self.message;
        if (self.seen)
            self.pfObject[@"seen"] = self.seen;
        if (self.toUserID)
            self.pfObject[@"toUserID"] = self.toUserID;
        if (self.itemID)
            self.pfObject[@"itemID"] = self.itemID;

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

#pragma mark Query
+(void)queryForInfo:(NSDictionary *)info completion:(void(^)(NSArray *results, NSError *error))competion{
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    for (id key in info.allKeys) {
        [query whereKey:key equalTo:info[key]];
    }
    [query findObjectsInBackgroundWithBlock:competion];
}

@end
