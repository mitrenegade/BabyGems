//
//  Album+Validation.m
//  BabyGems
//
//  Created by Bobby Ren on 12/17/14.
//  Copyright (c) 2014 BobbyRenTech. All rights reserved.
//

#import "Album+Validation.h"
#import "Album+Parse.h"
@implementation Album (Validation)

-(BOOL)validateForInsert:(NSError *__autoreleasing *)error {
    BOOL valid = [super validateForInsert:error];

    id valueToValidate = [self valueForKey:@"isDefault"];

    //validate for uniqueness on isDefault attribute - only one album can be default
    if ([valueToValidate boolValue]) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isDefault = 1"];

        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:nil];

        if (count > 1){
            NSLog(@"Default album already exists, cannot save");
            [self.pfObject deleteInBackground];
            [self.managedObjectContext deleteObject:self];
            [self notify:@"album:deleted" object:nil userInfo:nil];
        }
    }
    return valid;
}
@end
