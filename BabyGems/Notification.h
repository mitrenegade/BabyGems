//
//  Notification.h
//  BabyGems
//
//  Created by Bobby Ren on 1/3/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"


@interface Notification : ParseBase

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * seen;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * toUserID;
@property (nonatomic, retain) NSString * itemID;

@end
