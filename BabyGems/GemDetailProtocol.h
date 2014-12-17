//
//  GemDetailProtocol.h
//  BabyGems
//
//  Created by Bobby Ren on 12/17/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Album;
@class Gem;

@protocol GemDetailDelegate <NSObject>

-(void)didMoveGem:(Gem *)gem toAlbum:(Album *)album;
-(void)deleteGem:(Gem *)gem;
-(void)shareGem:(Gem *)gem;

@end
