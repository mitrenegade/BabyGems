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
    if ([segue.identifier isEqualToString:@"InitialAddGem"]) {
        UINavigationController *nav = [segue destinationViewController];
        NewGemViewController *controller = [nav.viewControllers lastObject];
        controller.delegate = self;
    }
}

#pragma mark NewGemDelegate
-(void)dismissNewGem {
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"InitialGemBox" sender:self];
    }];
}
-(void)didSaveNewGem {
    [self dismissNewGem];
}

#pragma mark Parse
-(void)synchronizeWithParse {
    // make sure all parse objects are in core data
    NSArray *classes = @[@"Gem"];

    for (NSString *className in classes) {
        PFQuery *query = [PFQuery queryWithClassName:className];
        PFUser *user = _currentUser;
        [user fetchIfNeeded];
        [query whereKey:@"pfUserID" equalTo:_currentUser.objectId];
        NSLog(@"Querying for %@ for organization %@", className, _currentUser[@"organization"]);

        if ([className isEqualToString:@"Gem"]) {
            NSLog(@"Before sync:");
            [_appDelegate printAll];
        }
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
            }
            else {
                NSLog(@"Synchronizing class %@", className);
                [ParseBase synchronizeClass:className fromObjects:objects replaceExisting:YES completion:^{
                    // reload
                    [self notify:@"gems:updated"];

                    if ([className isEqualToString:@"Gem"]) {
                        NSLog(@"After sync:");
                        [_appDelegate printAll];
                    }
                }];
            }
        }];
    }
}

@end
