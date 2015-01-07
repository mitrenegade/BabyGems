//
//  PFUser+Info.m
//  BabyGems
//
//  Created by Bobby Ren on 1/7/15.
//  Copyright (c) 2015 BobbyRenTech. All rights reserved.
//

#import "PFUser+Info.h"

@implementation PFUser (Info)

-(NSString *)fullName {
    if (self[@"name"])
        return self[@"name"];
    else if (self[@"firstName"])
        return self[@"firstName"];
    else if (self[@"email"])
        return self[@"email"];
    return nil;
}
@end
