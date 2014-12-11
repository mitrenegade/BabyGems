//
//  AlbumsViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumsViewController : UICollectionViewController
{
    NSFetchedResultsController *albumFetcher;
    NSFetchedResultsController *gemFetcher;
}
@end
