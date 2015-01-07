//
//  FacebookHelper.h
//  BabyGems
//
//  Created by Bobby Ren on 11/12/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookHelper : NSObject
+(void)loginWithFacebookWithCompletion:(void(^)(PFUser *user)) completion;
+(void)getInfoForUser:(PFUser *)user completion:(void(^)(NSDictionary *results, NSError *error)) completion;
+(void)updateCanonicalInfoForUser:(PFUser *)user fullName:(NSString *)fullName firstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email;

@end
