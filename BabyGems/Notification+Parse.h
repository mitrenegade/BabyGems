//
//  Notification+Parse.h
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "Notification.h"
#import "ParseBase+Parse.h"

@interface Notification (Parse) <PFObjectFactory>

+(void)queryForInfo:(NSDictionary *)info completion:(void(^)(NSArray *results, NSError *error))competion;

@end
