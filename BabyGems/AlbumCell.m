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

@implementation AlbumCell

-(void)setupWithAlbum:(Album *)album {
    self.labelName.text = album.name;
    self.labelDate.text = [album dateString];
    self.labelCount.text = [NSString stringWithFormat:@"%lu gems", (unsigned long)[album.gems count]];

}
@end
