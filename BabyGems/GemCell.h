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

@property (nonatomic, weak) Gem *gem;
@property (nonatomic, weak) IBOutlet UILabel *labelQuote;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintLabelHeight;
@property (nonatomic, weak) IBOutlet UILabel *labelCommentCount;
@property (nonatomic, weak) IBOutlet UILabel *labelDate;
@property (nonatomic, weak) IBOutlet UIView *viewBorder;
@property (nonatomic, assign) BOOL showBorder;

-(void)setupForGem:(Gem *)gem;
@end
