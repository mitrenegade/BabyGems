//
//  InitialViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "InitialViewController.h"
#import "GemBoxViewController.h"
#import "ParseBase+Parse.h"
#import "Gem+Parse.h"
#import "Album+Info.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

#if AIRPLANE_MODE
    [self performSegueWithIdentifier:@"InitialGemBox" sender:nil];
#else
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"InitialGemBox" sender:nil];
        [self synchronizeWithParse];
    }
    else {
        [_appDelegate goToLoginSignup];
    }
    [self listenFor:@"mainView:show" action:@selector(showMainView)];
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self stopListeningFor:@"mainView:show"];
}

-(void)showMainView {
    [self performSegueWithIdentifier:@"InitialGemBox" sender:nil];
    [self synchronizeWithParse];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"InitialGemBox"]) {
        UIViewController *controller = segue.destinationViewController;
        _appDelegate.topViewController = controller;
    }
}

#pragma mark Parse
-(void)synchronizeWithParse {

#if TESTING && 0
    // force clean start
    for (Album *album in [[Album where:@{}] all])
        [_appDelegate.managedObjectContext deleteObject:album];
    for (Gem *gem in [[Gem where:@{}] all])
        [_appDelegate.managedObjectContext deleteObject:gem];
#endif

    // make sure all parse objects are in core data
//    NSArray *classes = @[@"Gem", @"Album"];

    [self synchronizeClass:@"Album" completion:^(BOOL success) {
        // first get all albums
        NSLog(@"Albums after sync:");
        [_appDelegate printAllAlbums];

        [self synchronizeClass:@"Gem" completion:^(BOOL success) {
            [self createOrUpdateDefaultAlbumWithCompletion:^(BOOL success) {
                NSLog(@"Gems after sync:");
                [_appDelegate printAllGems];

                [self notify:@"gems:updated"];
                [self notify:@"sync:complete"];
            }];
        }];
    }];

    [self loadNotifications];
}

-(void)synchronizeClass:(NSString *)className completion:(void(^)(BOOL success))completion {
    PFQuery *query = [PFQuery queryWithClassName:className];
    PFUser *user = _currentUser;
    [user fetchIfNeeded];
    [query whereKey:@"pfUserID" equalTo:_currentUser.objectId];
    NSLog(@"Querying for %@ for user %@", className, _currentUser.objectId);

    if ([className isEqualToString:@"Album"]) {
        NSLog(@"Albums before sync:");
        [_appDelegate printAllAlbums];
    }
    if ([className isEqualToString:@"Gem"]) {
        NSLog(@"Gems before sync:");
        [_appDelegate printAllGems];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Synchronizing class %@", className);
            [ParseBase synchronizeClass:className fromObjects:objects replaceExisting:YES completion:^{
                if (completion) {
                    completion(YES);
                }
            }];
        }
    }];
}

-(void)loadNotifications {
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    PFUser *user = _currentUser;
    [user fetchIfNeeded];
    [query whereKey:@"pfUserID" equalTo:_currentUser.objectId];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Notifications: %@", objects);
        [_appDelegate printAllNotifications];
    }];
}

#pragma mark Default album
-(void)createOrUpdateDefaultAlbumWithCompletion:(void(^)(BOOL success))completion {
    Album *defaultAlbum = [Album defaultAlbum];
    if (!defaultAlbum) {
        NSLog(@"No default album");
        defaultAlbum = (Album *)[Album createEntityInContext:_appDelegate.managedObjectContext];
        defaultAlbum.startDate = [NSDate date];
        defaultAlbum.name = @"Default album";
        defaultAlbum.isDefault = @YES;
    }

    NSArray *gems = [[Gem where:@{@"album":[NSNull null]}] all];
    for (Gem *gem in gems) {
        gem.album = defaultAlbum;
        [gem saveOrUpdateToParseWithCompletion:nil];
    }

    [defaultAlbum saveOrUpdateToParseWithCompletion:^(BOOL success) {
        NSLog(@"Success %d id %@", success, defaultAlbum.parseID);
    }];

    [_appDelegate saveContext];
    if (completion)
        completion(YES);
}

@end
