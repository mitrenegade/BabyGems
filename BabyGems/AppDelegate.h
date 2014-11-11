//
//  AppDelegate.h
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)goToLoginSignup;
-(void)goToMainView;
@end
