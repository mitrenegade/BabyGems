//
//  Copyright (c) 2013 Luke Scott
//  https://github.com/lukescott/DraggableCollectionView
//  Distributed under MIT license
//

#import <UIKit/UIKit.h>
#import "UICollectionView+Draggable.h"
#import "CameraViewController.h"
#import "NewGemViewController.h"
#import "AlbumsViewController.h"
#import "GemDetailCollectionViewController.h"

@class Album;
@interface GemBoxViewController : UIViewController <UICollectionViewDataSource_Draggable, UICollectionViewDelegate, NewGemDelegate, CameraDelegate, UIAlertViewDelegate, GemDetailCollectionDelegate>
{
    NSPredicate *albumPredicate;

    CameraViewController *cameraController;
    IBOutlet UIView *viewBG;

    UIImage *savedImage;
    NSString *savedQuote;
    NSDictionary *savedMeta;

    UIView *tutorialView;
}
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) Album *currentAlbum;
@end
