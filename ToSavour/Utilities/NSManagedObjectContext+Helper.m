//
//  NSManagedObjectContext+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 10/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "NSManagedObjectContext+Helper.h"

@implementation NSManagedObjectContext (Helper)

- (void)save {
    NSError *error = nil;
    if ([self hasChanges] && ![self save:&error]) {
        DDLogError(@"unresolved error saving context: %@ %@", error, error.userInfo);
        NSAssert(NO, @"unresolved error saving context: %@ %@", error, error.userInfo);
    }
}

@end
