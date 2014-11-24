//
//  GemCell.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemCell.h"
#import "Gem+Parse.h"
#import "AsyncImageView.h"

@implementation GemCell

-(void)setupForGem:(Gem *)gem {
    self.gem = gem;
    NSLog(@"Gem.id: %@", gem.parseID);
    if (gem.quote) {
        self.labelQuote.text = gem.quote;
    }
}
@end
