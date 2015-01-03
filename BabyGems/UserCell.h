//
//  UserCell.h
//  BabyGems
//
//  Created by Bobby Ren on 1/2/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
{
    IBOutlet UILabel *labelName;
    IBOutlet UIImageView *icon;
}

-(void)setupWithUser:(PFUser *)user;
-(void)toggleSelected:(BOOL)selected;

@end
