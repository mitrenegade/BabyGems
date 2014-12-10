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
#import "Util.h"

@implementation GemCell

-(void)setupForGem:(Gem *)gem {
    self.gem = gem;
    if (gem.quote.length) {
        self.labelQuote.text = [NSString stringWithFormat:@"“%@”", gem.quote];
    }
    else {
        self.labelQuote.text = @"";
    }

    [self setupBorder];

    NSDate *date = gem.createdAt;
    if (date) {
        NSString *timeAgo = [Util timeAgo:date];
        self.labelDate.text = timeAgo;
    }
    else {
        self.labelDate.text = nil;
    }

    // todo: make real comment count
    int comments = 0;
#if TESTING
    comments = arc4random() % 25;
#endif
    self.labelCommentCount.text = [NSString stringWithFormat:@"%d", comments];
}

-(void)setupBorder {
    self.viewBorder.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    if (self.borderStyle == BorderStyleRound) {
        self.viewBorder.layer.borderWidth = 1;
        self.viewBorder.layer.cornerRadius = 5;
    }
    else {
        self.viewBorder.layer.borderWidth = 0;
        self.viewBorder.layer.cornerRadius = 0;
    }
}

@end
