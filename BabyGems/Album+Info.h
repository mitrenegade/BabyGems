//
//  Album+Info.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album.h"

typedef enum AlbumOwnershipType {
    ALBUM_OWNED,
    ALBUM_SHARED,
    ALBUM_INACCESSIBLE
} AlbumOwnership;

@class Gem;
@interface Album (Info)

-(NSString *)dateString;
-(Gem *)coverGem;
-(NSArray *)sortedGems;

-(BOOL)isOwned;
-(BOOL)isShared;

+(Album *)defaultAlbum;
@end
