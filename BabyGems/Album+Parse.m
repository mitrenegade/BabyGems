//
//  Album+Parse.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album+Parse.h"

@implementation Album (Parse)

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
    self.name = [self.pfObject objectForKey:@"name"];
    self.longDescription = [self.pfObject objectForKey:@"longDescription"];
    self.startDate = [self.pfObject objectForKey:@"startDate"];
    self.endDate = [self.pfObject objectForKey:@"endDate"];
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    [super saveOrUpdateToParseWithCompletion:^(BOOL success) {

        if (self.name)
            self.pfObject[@"name"] = self.name;
        if (self.longDescription)
            self.pfObject[@"longDescription"] = self.longDescription;
        if (self.startDate)
            self.pfObject[@"startDate"] = self.startDate;
        if (self.endDate)
            self.pfObject[@"endDate"] = self.endDate;

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
