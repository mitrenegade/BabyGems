//
//  AlbumFlowLayout.h
//  BabyGems
//
//  Created by Bobby Ren on 12/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewLayout_Warpable.h"
#import "LSCollectionViewLayoutHelper.h"

#define CELL_HEIGHT 160

@interface AlbumFlowLayout : UICollectionViewFlowLayout <UICollectionViewLayout_Warpable>

@property (readonly, nonatomic) LSCollectionViewLayoutHelper *layoutHelper;

@end
