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

@property (nonatomic, weak) IBOutlet UILabel *labelQuote;
@property (nonatomic, weak) Gem *gem;

-(void)setupForGem:(Gem *)gem;
@end
