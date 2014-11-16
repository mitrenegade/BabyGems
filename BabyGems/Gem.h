//
//  Gem.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ParseBase.h"


@interface Gem : ParseBase

@property (nonatomic, retain) NSString * quote;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSData * offlineImage;

@end
