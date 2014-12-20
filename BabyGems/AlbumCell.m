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
#import "AsyncImageView.h"
#import "Gem+Info.h"

@implementation AlbumCell

-(void)setupWithAlbum:(Album *)album {
    [self setupBorder];
    [self setupName:album.name];
    self.labelCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[album.gems count]];

    Gem *gem = [album coverGem];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = gem.offlineImage?[UIImage imageWithData:gem.offlineImage]:nil;
    self.imageView.imageURL = [NSURL URLWithString:gem.imageURL];
    self.viewCountBG.hidden = NO;
}

-(void)setupForNewAlbum {
    [self setupBorder];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.image = [UIImage imageNamed:@"plus"];
    self.imageView.imageURL = nil;
    [self setupName:@"Create a new album"];
    self.viewCountBG.hidden = YES;
}

-(void)setupName:(NSString *)name {
    UIFont *font = self.labelName.font;
    CGRect rect = [name boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    self.constraintHeightName.constant = rect.size.height;
    self.labelName.text = name;
}

-(void)setupBorder {
    self.imageView.crossfadeDuration = 0;

    self.viewBG.layer.borderWidth = 2;
    self.viewBG.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewBG.layer.cornerRadius = 5;
    // todo: if current album, different border color

    self.viewCountBG.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.viewCountBG.layer.borderWidth = 1;
    self.viewCountBG.layer.cornerRadius = self.viewCountBG.frame.size.width / 2;
}

-(void)isCurrentAlbum {
    self.viewBG.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.viewBG.layer.borderWidth = 3;
}
@end
