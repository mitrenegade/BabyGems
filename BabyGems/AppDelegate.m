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
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Gem+Info.h"
#import "Album+Info.h"
#import "Util.h"
#import "NewGemViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"

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

    [Fabric with:@[CrashlyticsKit]];

#if TESTING
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];

    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
#endif

    [self printAllGems];

    [self loadCellStyle];
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

#pragma mark - Core Data stack
// the code below was generated by xcode 6 when creating a core data application

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "tech.bobbyren.BRCoreDataTest" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)storeURL {
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BabyGems.sqlite"];
    return storeURL;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [self storeURL];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    if (!store) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

        // delete store and start over
    }
    if (![_managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:[_persistentStoreCoordinator metadataForPersistentStore:store]]) {
        NSError *error;

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [self resetCoreData];
    }

    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)resetCoreData {
    NSLog(@"Resetting core data");
    [self.managedObjectContext lock];
    [self.managedObjectContext reset];

    NSError *error;
    NSURL *storeURL = [self storeURL];
    NSPersistentStore *store = [self.persistentStoreCoordinator persistentStoreForURL:storeURL];
    if (store)
        [self.persistentStoreCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];

    [self.managedObjectContext unlock];

    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _managedObjectModel = nil;
}

#pragma mark CoreData - old
/*
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

 */

-(void)loadCellStyle {
#if TESTING
    self.cellStyle = CellStyleFirst;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:cellstyle"]) {
        self.cellStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:cellstyle"];
    }
    self.borderStyle = BorderStyleFirst;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:borderstyle"]) {
        self.borderStyle = [[NSUserDefaults standardUserDefaults] integerForKey:@"defaults:borderstyle"];
    }
#else
    self.cellStyle = CellStyleBottom;
    self.borderStyle = BorderStyleRound;
#endif
}

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


#pragma mark core data object helpers
-(Gem *)newGem {
    Gem *object = (Gem *)[Gem createEntityInContext:self.managedObjectContext];
    object.quote = [Util timeStringForDate:[NSDate date]];
    return object;
}

-(void)printAllGems {
    NSArray *all = [[Gem where:@{}] all];
    NSLog(@"%lu gems found", (unsigned long)[all count]);
    for (Gem *gem in all) {
        NSLog(@"Gem: quote: %@ order %@ createdAt: %@ album: %@", gem.quote, gem.order, gem.createdAt, gem.album.parseID);
    }
}

-(void)printAllAlbums {
    NSArray *all = [[Album where:@{}] all];
    NSLog(@"%lu albums found", (unsigned long)[all count]);
}

#pragma mark Reused calls
#pragma mark Settings
-(void)showSettings {
    NSString *message = [NSString stringWithFormat:@"About: BabyGems v%@\nCopyright 2014 Bobby Ren", VERSION];
    NSArray *menuOptions = @[@"Contact us", @"View website", @"Toggle photo options"];
#if TESTING
    menuOptions = [menuOptions arrayByAddingObject:@"Admin"];
#endif
    [UIActionSheet actionSheetWithTitle:message message:nil buttons:menuOptions showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            [self goToFeedback];
        }
        else if (buttonIndex == 1) {
            [self goToTOS];
        }
        else if (buttonIndex == 2) {
            [NewGemViewController toggleSaveToAlbum];
        }
        else {
#if TESTING
            [self showAdmin];
#endif
        }
    } onCancel:^{
        // do nothing
    }];
}

#pragma mark Website
-(void)goToTOS {
    NSString *url = @"http://www.babygems.photos/";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}


#pragma mark Mail composer
-(void)goToFeedback {
    if ([MFMailComposeViewController canSendMail]){
        NSString *title = @"BabyGems feedback";
        NSString *message = [NSString stringWithFormat:@"Version %@", VERSION];
        MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
        composer.mailComposeDelegate = self;
        [composer setSubject:title];
        [composer setToRecipients:@[@"bobbyren+babygems@gmail.com"]];
        [composer setMessageBody:message isHTML:NO];

        [_appDelegate.topViewController presentViewController:composer animated:YES completion:nil];
    }
    else {
        [UIAlertView alertViewWithTitle:@"Currently unable to send email" message:@"Please make sure email is available"];
    }
}

#pragma mark MessageController delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //feedbackMsg.text = @"Result: Mail sending canceled";
            break;
        case MFMailComposeResultSaved:
            //feedbackMsg.text = @"Result: Mail saved";
            break;
        case MFMailComposeResultSent:
            //feedbackMsg.text = @"Result: Mail sent";
            [UIAlertView alertViewWithTitle:@"Thanks for your feedback" message:nil];
            break;
        case MFMailComposeResultFailed:
            //feedbackMsg.text = @"Result: Mail sending failed";
            [UIAlertView alertViewWithTitle:@"There was an error sending feedback" message:nil];
            break;
        default:
            //feedbackMsg.text = @"Result: Mail not sent";
            break;
    }
    // dismiss the composer
    [_appDelegate.topViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark Admin settings
-(void)showAdmin {
    [UIActionSheet actionSheetWithTitle:@"Please select an option to toggle (in test mode)" message:nil buttons:@[@"Toggle cell style", @"Toggle cell border"] showInView:_appDelegate.window onDismiss:^(int buttonIndex) {
        if (buttonIndex == 0) {
            [self toggleCellStyle];
        }
        else if (buttonIndex == 1) {
            [self toggleCellBorder];
        }
    } onCancel:^{
        // do nothing
    }];
}

-(void)toggleCellStyle {
    self.cellStyle += 1;
    if (self.cellStyle == CellStyleMax)
        self.cellStyle = CellStyleFirst;

    [[NSUserDefaults standardUserDefaults] setInteger:self.cellStyle forKey:@"defaults:cellstyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self notify:@"style:changed"];
}

-(void)toggleCellBorder {
    self.borderStyle += 1;
    if (self.borderStyle == BorderStyleMax)
        self.borderStyle = BorderStyleFirst;

    [[NSUserDefaults standardUserDefaults] setInteger:self.borderStyle forKey:@"defaults:borderstyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self notify:@"style:changed"];
}
@end
