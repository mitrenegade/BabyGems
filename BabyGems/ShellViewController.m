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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];

    [self listenFor:@"notifications:hide" action:@selector(hideNotificationAlert)];
    [self listenFor:@"notifications:set" action:@selector(setNotificationsCount:)];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark Messages
-(void)hideNotificationAlert {
    [UIView animateWithDuration:1 animations:^{
        notificationAlertView.alpha = 0;
    }];
}

-(void)setNotificationsCount:(NSNotification *)n {
    NSDictionary *userInfo = n.userInfo;
    NSNumber *count = userInfo[@"count"];
    notificationAlertView.text = [NSString stringWithFormat:@"%@", count];

    if ([count intValue] > 0) {
        notificationAlertView.backgroundColor = [UIColor redColor];
        notificationAlertView.textColor = [UIColor whiteColor];
    }
    else {
        notificationAlertView.backgroundColor = [UIColor whiteColor];
        notificationAlertView.textColor = [UIColor darkGrayColor];
    }

    [UIView animateWithDuration:1 animations:^{
        notificationAlertView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Gestures
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    if (CGRectContainsPoint(notificationAlertView.frame, point))
        return YES;
    return NO;
}

-(void)handleGesture:(UIGestureRecognizer *)gesture {
    [self performSegueWithIdentifier:@"ShowNotifications" sender:self];
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
