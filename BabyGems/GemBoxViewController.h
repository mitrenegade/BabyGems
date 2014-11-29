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

typedef enum GemCellStyleEnum {
    CellStyleFirst,
    CellStyleFull = CellStyleFirst,
    CellStyleBottom,
    CellStyleMax
} GemCellStyle;

typedef enum GemBorderStyleEnum {
    BorderStyleFirst,
    BorderStyleNone = BorderStyleFirst,
    BorderStyleRound,
    BorderStyleMax
} GemBorderStyle;

@interface GemBoxViewController : UICollectionViewController <NewGemDelegate, CameraDelegate, UIAlertViewDelegate>
{
    NSFetchedResultsController *__gemFetcher;
    CameraViewController *cameraController;
    IBOutlet UIView *viewBG;

    UIImage *savedImage;
    NSString *savedQuote;

    GemCellStyle cellStyle;
    GemBorderStyle borderStyle;
}

-(NSFetchedResultsController *)gemFetcher;

@end
