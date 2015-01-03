//
//  UserCell.m
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "UserCell.h"
#import <Parse/Parse.h>

@implementation UserCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupWithUser:(PFUser *)user {
    labelName.text = user.username;
}

-(void)toggleSelected:(BOOL)selected {
    if (selected) {
        icon.image = [UIImage imageNamed:@"circleCheck"];
    }
    else {
        icon.image = [UIImage imageNamed:@"circleNoCheck"];
    }
}
@end
