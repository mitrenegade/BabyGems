//
//  Gem.h
//  BabyGems
//
//  Created by Bobby Ren on 12/17/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class Album;

@interface Gem : ParseBase

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSData * offlineImage;
@property (nonatomic, retain) NSString * quote;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Album *album;

@end
