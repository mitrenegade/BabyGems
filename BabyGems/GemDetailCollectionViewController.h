//
//  GemDetailCollectionViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 12/16/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GemDetailProtocol.h"

@protocol GemDetailCollectionDelegate <NSObject>

-(NSArray *)sortedGems;
-(Gem *)gemAtIndexPath:(NSIndexPath *)indexPath;

@end

@class Gem;
@interface GemDetailCollectionViewController : UICollectionViewController <GemDetailDelegate>

@property (nonatomic, weak) id delegate;
@end
