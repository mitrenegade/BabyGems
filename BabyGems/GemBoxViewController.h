//
//  GemBoxViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import "NewGemViewController.h"
#import "AlbumsViewController.h"
#import "GemDetailCollectionViewController.h"

@class Album;
@interface GemBoxViewController : UICollectionViewController <NewGemDelegate, CameraDelegate, UIAlertViewDelegate, GemDetailCollectionDelegate>
{
    NSPredicate *albumPredicate;

    CameraViewController *cameraController;
    IBOutlet UIView *viewBG;

    UIImage *savedImage;
    NSString *savedQuote;
    NSDictionary *savedMeta;

    UIView *tutorialView;
}

@property (strong, nonatomic) Album *currentAlbum;

//-(NSFetchedResultsController *)gemFetcher;

@end
