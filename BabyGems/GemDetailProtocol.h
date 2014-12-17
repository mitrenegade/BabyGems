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

-(NSInteger)currentOrderForGem:(Gem *)gem;
-(NSInteger)totalGemsInAlbum;
-(void)didMoveGem:(Gem *)gem toPosition:(NSInteger)newPos;

-(void)showAlbumSelectorForGem:(Gem *)gem;
-(void)deleteGem:(Gem *)gem;
-(void)shareGem:(Gem *)gem image:(UIImage *)image;

@end
