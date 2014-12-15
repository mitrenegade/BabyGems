//
//  AlbumCell.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@class AsyncImageView;
@interface AlbumCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet AsyncImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;
@property (weak, nonatomic) IBOutlet UIView *viewCountBG;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightName;

@property (weak, nonatomic) Album *album;

-(void)setupWithAlbum:(Album *)album;
-(void)setupForDefaultAlbumWithGems:(NSArray *)gems;
-(void)setupForNewAlbum;
@end
