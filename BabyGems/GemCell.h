//
//  GemCell.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Gem;
@interface GemCell : UICollectionViewCell
{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *labelQuote;
}
//@property (nonatomic, weak) IBOutlet UIImageView *imageView;
//@property (nonatomic, weak) IBOutlet UILabel *labelQuote;

-(void)setupForGem:(Gem *)gem;
@end
