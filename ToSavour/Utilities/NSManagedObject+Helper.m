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

- (void)deleteInContext:(NSManagedObjectContext *)context {
    if (!context) {
        context = self.managedObjectContext;
    }
    NSManagedObjectID *objectID = self.objectID;
    NSManagedObject *selfInContext = [context objectWithID:objectID];
    [context deleteObject:selfInContext];
}

+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context {
    return [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self.class)];
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
    [context saveToPersistentStore:&error];
    if (error) {
        DDLogError(@"error in saving changes after removing all objects for entity: %@", self.class);
    }
}

@end
