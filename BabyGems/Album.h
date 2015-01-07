//
//  Album.h
//  BabyGems
//
//  Created by Bobby Ren on 1/4/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"

@class Gem;

@interface Album : ParseBase

@property (nonatomic, retain) NSNumber * customOrder;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * ownership;
@property (nonatomic, retain) NSSet *gems;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addGemsObject:(Gem *)value;
- (void)removeGemsObject:(Gem *)value;
- (void)addGems:(NSSet *)values;
- (void)removeGems:(NSSet *)values;

@end
