//
//  InitialViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/15/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "InitialViewController.h"
#import "GemBoxViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

#if AIRPLANE_MODE
    [self performSegueWithIdentifier:@"InitialAddGem" sender:nil];
#else
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"InitialAddGem" sender:nil];
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
    [self performSegueWithIdentifier:@"InitialAddGem" sender:nil];
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


@end
