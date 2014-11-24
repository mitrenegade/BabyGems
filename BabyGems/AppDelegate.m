//
//  AppDelegate.m
//  BRSimpleLoginSignup
//
//  Created by Bobby Ren on 7/2/14.
//  Copyright (c) 2014 BRSimpleLoginSignup. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"7ed10Q7iOMBLppi3FXzApRhmaQxsJdXlS8sbBbaN"
                  clientKey:@"re1mhkjLyyv31TdzwqlvbPiSIIKMUBjXdll5e1Nw"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [PFFacebookUtils initializeFacebook];

    [Crashlytics startWithAPIKey:@"70160b7dec925a91c6fe09e38bf1f8659c1eda41"];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

#pragma mark CoreData
- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    else {
        NSLog(@"Error no persistent store");
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BabyGems.sqlite"];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];

    if (![_managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:[_persistentStoreCoordinator metadataForPersistentStore:store]]) {
        NSError *error;

        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    }

    return _persistentStoreCoordinator;
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//- (NSString *)applicationDocumentsDirectory {
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}

#pragma mark navigation
-(void)goToLoginSignup {
    UINavigationController *nav = [_storyboard(@"LoginSignup") instantiateInitialViewController];
    [_appDelegate.window.rootViewController presentViewController:nav animated:NO completion:nil];
}

-(void)goToMainView {
    UINavigationController *nav = (UINavigationController *)_appDelegate.window.rootViewController;
    if (nav.presentedViewController) {
        [nav dismissViewControllerAnimated:YES completion:^{
            [self notify:@"mainView:show"];
        }];
    }
}
@end
