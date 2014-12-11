//
//  AlbumCell.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "AlbumCell.h"
#import "Album+Info.h"
#import "Util.h"
#import "Gem+Info.h"

@implementation AlbumCell

-(void)setupWithAlbum:(Album *)album {
    [self setupBorder];
    self.labelName.text = album.name;
    self.labelDate.text = [album dateString];
    self.labelCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[album.gems count]];
}

-(void)setupForDefaultAlbumWithGems:(NSArray *)gems {
    [self setupBorder];
    self.labelName.text = @"Your default album";
    NSDate *date = [gems[0] createdAt];
    self.labelDate.text = [Util timeAgo:date compact:NO];
    self.labelCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[gems count]];
}

-(void)setupBorder {
    self.viewBG.layer.borderWidth = 2;
    self.viewBG.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.viewBG.layer.cornerRadius = 5;

    // todo: if current album, different border color
}
@end
