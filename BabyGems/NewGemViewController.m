//
//  NewGemViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/11/14.
//  Copyright (c) 2014 SEVEN. All rights reserved.
//

#import "NewGemViewController.h"

@interface NewGemViewController ()

@end

@implementation NewGemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([PFUser currentUser]) {
    }
    else {
        [_appDelegate goToLoginSignup];
    }

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

-(void)goToIntro {
}
@end
