//
//  GemCell.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemCell.h"
#import "Gem+Parse.h"

@implementation GemCell

-(void)setupForGem:(Gem *)gem {
    NSLog(@"Gem.id: %@", gem.parseID);
    NSData *data = gem.offlineImage;
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        imageView.image = image;
    }
    // todo: populate from url

    if (gem.quote) {
        labelQuote.text = gem.quote;
    }
}
@end
