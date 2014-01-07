//
//  NSManagedObject+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 3/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "NSManagedObject+Helper.h"

@implementation NSManagedObject (Helper)

+ (NSManagedObject *)newObjectInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
}

+ (NSManagedObject *)existingOrNewObjectInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequest = [self.class fetchRequestInContext:context];
    fetchRequest.predicate = predicate;
    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if (fetchResults.count > 0) {
            if (fetchResults.count > 1) {
                DDLogWarn(@"found duplicates when fetching existing managed object: %@", fetchResults);
            }
            return fetchResults[0];
        } else {
            return [self.class newObjectInContext:context];
        }
    } else {
        DDLogError(@"error fetching existing managed object: %@", error);
    }
    return nil;
}

- (void)deleteInContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = self.managedObjectContext;
    }
    NSManagedObjectID *objectID = self.objectID;
    NSManagedObject *selfInContext = [context objectWithID:objectID];
    [context deleteObject:selfInContext];
}

//Maximal: why do you need context in this method?
+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.class)];
    fetchRequest.sortDescriptors = @[]; // a NSFetchRequest must have sortDescriptors, default empty array
    return fetchRequest;
}

+ (void)removeALlObjectsInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [self.class fetchRequestInContext:context];
    fetchRequest.includesPropertyValues = NO;  // only fetch the managedObjectID
    fetchRequest.includesPendingChanges = YES;
    NSError *error = nil;
    NSArray *allObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error in removing all objects for entity: %@", self.class);
        return;
    }
    for (NSManagedObject *object in allObjects) {
        [context deleteObject:object];
    }
    [context save:&error];
    if (error) {
        DDLogError(@"error in saving changes after removing all objects for entity: %@", self.class);
    }
}

@end
