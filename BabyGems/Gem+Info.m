//
//  Gem+Info.m
//  BabyGems
//
//  Created by Bobby Ren on 11/24/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Gem+Info.h"

@implementation Gem (Info)

-(BOOL)isPhotoGem {
    return self.imageURL || self.offlineImage;
}

-(void)updateTextPosition:(CGPoint)origin inFrame:(CGRect)frameOfEnclosingView {
    NSLog(@"origin: %f %f frame size: %f %f", origin.x, origin.y, frameOfEnclosingView.size.width, frameOfEnclosingView.size.height);
    self.textPositionByPercent = @(origin.y / frameOfEnclosingView.size.height);
}

@end
