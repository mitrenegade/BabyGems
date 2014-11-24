//
//  GemPhotoCell.m
//  BabyGems
//
//  Created by Bobby Ren on 11/24/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemPhotoCell.h"
#import <AsyncImageView/AsyncImageView.h>
#import "Gem+Parse.h"

@implementation GemPhotoCell

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setupForGem:(Gem *)gem {
    [super setupForGem:gem];

    NSData *data = gem.offlineImage;
    if (data) {
        UIImage *image = [UIImage imageWithData:data];
        self.imageView.image = image;
    }
    else if (gem.imageURL) {
        self.imageView.imageURL = [NSURL URLWithString:gem.imageURL];
    }
    else {
        self.imageView.image = nil;
    }
}
@end
