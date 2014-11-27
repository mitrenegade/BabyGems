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
        AsyncImageView *view = (AsyncImageView *)self.imageView;
        view.imageURL = [NSURL URLWithString:gem.imageURL];
    }
    else {
        self.imageView.image = nil;
    }

    if (gem.quote) {
        NSString *text = gem.quote;
        UIFont *font = [UIFont fontWithName:@"Chalkduster" size:16];
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.frame.size.width, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        self.constraintLabelHeight.constant = rect.size.height + 40;
    }
}

-(void)setupBorder {
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

@end
