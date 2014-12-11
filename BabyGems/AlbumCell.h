//
//  AlbumCell.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Album;
@interface AlbumCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;

@property (weak, nonatomic) Album *album;

-(void)setupWithAlbum:(Album *)album;
-(void)setupForDefaultAlbumWithGems:(NSArray *)gems;

@end
