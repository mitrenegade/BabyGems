//
//  Album+Parse.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album+Parse.h"
#import "Album+Info.h"
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
    self.isDefault = [self.pfObject objectForKey:@"isDefault"];
    self.customOrder = [self.pfObject objectForKey:@"customOrder"];

    if ([self.pfUserID isEqualToString:_currentUser.objectId]) {
        self.ownership = @(ALBUM_OWNED);
    }
    else {
        self.ownership = @(ALBUM_SHARED); // bobby todo: create User object so we can have sharedWith relationship to user in core data
    }
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
        if (self.isDefault)
            self.pfObject[@"isDefault"] = self.isDefault;
        if (self.customOrder)
            self.pfObject[@"customOrder"] = self.customOrder;

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
