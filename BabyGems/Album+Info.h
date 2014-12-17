//
//  Album+Info.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album.h"
@class Gem;
@interface Album (Info)

-(NSString *)dateString;
-(Gem *)coverGem;
-(NSArray *)sortedGems;
-(void)updateGemOrder;
@end
