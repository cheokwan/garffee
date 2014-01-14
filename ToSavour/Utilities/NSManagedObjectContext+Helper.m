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

- (NSManagedObject *)fetchUniqueObject:(NSFetchRequest *)fetchRequest {
    NSError *error = nil;
    NSArray *results = [self executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching unique object with fetch request %@: %@", fetchRequest, error);
    } else if (results.count > 1) {
        DDLogWarn(@"more than 1 object returned when fetching unique object %@: %@", fetchRequest, results);
    } else if (results.count == 1) {
        return results[0];
    }
    return nil;
}

@end
