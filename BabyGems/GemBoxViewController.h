//
//  GemBoxViewController.h
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GemBoxViewController : UICollectionViewController
{
    NSFetchedResultsController *__gemFetcher;
}

-(NSFetchedResultsController *)gemFetcher;

-(IBAction)didClickAddGem:(id)sender;
@end
