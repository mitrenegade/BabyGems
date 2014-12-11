//
//  Album+Info.m
//  BabyGems
//
//  Created by Bobby Ren on 12/11/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album+Info.h"
#import "Util.h"

@implementation Album (Info)

-(NSString *)dateString {
    NSDate *date = self.startDate?:self.createdAt;
    return [Util simpleTimeAgo:date];
}
@end
