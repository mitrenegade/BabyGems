//
//  AppDelegate.h
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Constants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, weak) UIViewController *topViewController;

@property (nonatomic, assign) GemCellStyle cellStyle;
@property (nonatomic, assign) GemBorderStyle borderStyle;

-(void)goToLoginSignup;
-(void)goToMainView;
- (void)saveContext;
-(void)printAllGems;
-(void)printAllAlbums;
-(void)printAllNotifications;
-(void)showSettings;
@end
