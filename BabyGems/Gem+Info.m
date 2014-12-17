//
//  Gem+Info.m
//  BabyGems
//
//  Created by Bobby Ren on 11/24/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Gem+Info.h"

@implementation Gem (Info)

-(BOOL)isPhotoGem {
    return self.imageURL || self.offlineImage;
}

@end
