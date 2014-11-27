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
    if (gem.quote) {
        self.labelQuote.text = [NSString stringWithFormat:@"“%@”", gem.quote];
    }

    [self setupBorder];
}

-(void)setupBorder {
    self.labelQuote.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.labelQuote.layer.borderWidth = 1;
    self.labelQuote.layer.cornerRadius = 5;
}
@end
