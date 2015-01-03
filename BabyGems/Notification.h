//
//  Notification.h
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"


@interface Notification : ParseBase

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * seen;

@end
