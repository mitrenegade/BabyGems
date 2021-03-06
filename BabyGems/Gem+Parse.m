//
//  Gem+Parse.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Gem+Parse.h"
#import "Album+Parse.h"

@implementation Gem (Parse)

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
    self.quote = [self.pfObject objectForKey:@"quote"];
    self.imageURL = [self.pfObject objectForKey:@"imageURL"];
    self.pfUserID = [self.pfObject objectForKey:@"pfUserID"];
    self.order = [self.pfObject objectForKey:@"order"];
    self.textPositionByPercent = [self.pfObject objectForKey:@"textPositionByPercent"];

    // relationships
    PFObject *object = [self.pfObject objectForKey:@"album"];
    if (object.objectId)
        self.album = [[[Album where:@{@"parseID":object.objectId}] all] firstObject];
}

-(void)saveOrUpdateToParseWithCompletion:(void (^)(BOOL))completion {
    [super saveOrUpdateToParseWithCompletion:^(BOOL success) {

        if (self.quote)
            self.pfObject[@"quote"] = self.quote;
        if (self.imageURL) {
            self.pfObject[@"imageURL"] = self.imageURL;
        }
        if (self.order)
            self.pfObject[@"order"] = self.order;
        if (self.textPositionByPercent)
            self.pfObject[@"textPositionByPercent"] = self.textPositionByPercent;

        if (_currentUser) {
            self.pfObject[@"user"] = _currentUser;
            self.pfObject[@"pfUserID"] = _currentUser.objectId;
        }
        // relationships
        if (self.album)
            self.pfObject[@"album"] = self.album.pfObject;

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
