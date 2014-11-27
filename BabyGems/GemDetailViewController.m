//
//  GemDetailViewController.m
//  BabyGems
//
//  Created by Bobby Ren on 11/27/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "GemDetailViewController.h"
#import "Gem.h"
#import <AsyncImageView/AsyncImageView.h>
#import "Gem+Parse.h"

@interface GemDetailViewController ()

@end

@implementation GemDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.gem) {
        NSData *data = self.gem.offlineImage;
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            self.imageView.image = image;
        }
        else if (self.gem.imageURL) {
            self.imageView.imageURL = [NSURL URLWithString:self.gem.imageURL];
        }
        else {
            self.imageView.image = nil;
        }
        

        if (self.gem.quote) {
            self.labelQuote.text = [NSString stringWithFormat:@"“%@”", self.gem.quote];
        }
        else {
            self.labelQuote.text = @"";
        }

        NSString *text = self.gem.quote;
        UIFont *font = [UIFont fontWithName:@"Chalkduster" size:16];
        CGRect rect = [text boundingRectWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        self.constraintQuoteHeight.constant = rect.size.height + 40;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)didClickShare:(id)sender {
    NSLog(@"Share!");
}

-(IBAction)didClickTrash:(id)sender {
    [UIAlertView alertViewWithTitle:@"Delete gem?" message:@"Are you sure you want to permanently delete this gem?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Delete Gem"] onDismiss:^(int buttonIndex) {
        [self.gem.pfObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [_appDelegate.managedObjectContext deleteObject:self.gem];
            }
            [self notify:@"gems:updated"];
        }];
    } onCancel:nil];
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
