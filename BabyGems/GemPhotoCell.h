//
//  GemPhotoCell.h
//  BabyGems
//
//  Created by Bobby Ren on 11/24/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemCell.h"

@class AsyncImageView;
@interface GemPhotoCell : GemCell

@property (nonatomic, weak) IBOutlet AsyncImageView *imageView;
@end
