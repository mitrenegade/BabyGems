//
//  AlbumsViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@protocol AlbumsViewDelegate <NSObject>
// called by GemDetailsViewController to move an album
-(void)didSelectAlbum:(Album *)album;

@end
@interface AlbumsViewController : UICollectionViewController <UIAlertViewDelegate>
{
    NSFetchedResultsController *albumFetcher;
}

@property (nonatomic, assign) int mode;
@property (weak, nonatomic) id<AlbumsViewDelegate> delegate;
@property (weak, nonatomic) Album *currentAlbum;
@end
