//
//  ShellViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 1/4/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "ShellViewController.h"

@interface ShellViewController ()

@end

@implementation ShellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    notificationAlertView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    notificationAlertView.layer.borderWidth = 2;
    notificationAlertView.layer.cornerRadius = notificationAlertView.frame.size.width/2;
    notificationAlertView.alpha = 0;
    notificationAlertView.center = CGPointMake(10+notificationAlertView.frame.size.width/2, _appDelegate.window.bounds.size.height - (10+notificationAlertView.frame.size.width/2));
    [self.view addSubview:notificationAlertView];

    [self listenFor:@"notifications:show" action:@selector(showNotificationAlert:)];
    [self listenFor:@"notifications:hide" action:@selector(hideNotificationAlert)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)showNotificationAlert:(NSNotification *)n {
    NSDictionary *userInfo = n.userInfo;
    NSNumber *count = userInfo[@"count"];
    notificationAlertView.text = [NSString stringWithFormat:@"%@", count];
    [UIView animateWithDuration:1 animations:^{
        notificationAlertView.alpha = 1;
    }];
}

-(void)hideNotificationAlert {
    [UIView animateWithDuration:1 animations:^{
        notificationAlertView.alpha = 0;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
