//
//  GemBoxViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewGemViewController.h"


@interface GemBoxViewController : UICollectionViewController <NewGemDelegate>
{
    NSFetchedResultsController *__gemFetcher;
    NewGemViewController *newGemController;
    IBOutlet UIView *viewBG;
}

-(NSFetchedResultsController *)gemFetcher;

@end
