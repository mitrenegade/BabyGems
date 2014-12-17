//
//  Album+Info.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album+Info.h"
#import "Util.h"
#import "Gem+Info.h"

@implementation Album (Info)

-(NSString *)dateString {
    NSDate *date = self.startDate?:self.createdAt;
    return [Util timeAgo:date compact:NO];
}

-(NSArray *)sortedGems {
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSSortDescriptor *descriptor0 = nil;
    if ([self.customOrder boolValue])
        descriptor0 = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *gems = [self.gems sortedArrayUsingDescriptors:[self.customOrder boolValue]?@[descriptor0, descriptor]:@[descriptor]];
    return gems;
}

-(Gem *)coverGem {
    // returns the most recent gem with an image, or the first gem if no image gems exist
    NSArray *sorted = [self sortedGems];
    for (int i=0; i<[sorted count]; i++) {
        if ([sorted[i] imageURL])
            return sorted[i];
    }
    return [sorted count]?sorted[0]:nil;
}

+(Album *)defaultAlbum {
    Album *defaultAlbum = [[[Album where:@{@"isDefault":@YES}] all] firstObject];
    return defaultAlbum;
}

@end
