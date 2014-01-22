//
//  NSManagedObject+Helper.h
//  ToSavour
//
//  Created by Jason Wan on 3/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Helper)

+ (NSManagedObject *)newObjectInContext:(NSManagedObjectContext *)context;
+ (NSManagedObject *)existingOrNewObjectInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
+ (NSManagedObject *)existingObjectInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
- (void)deleteInContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequest;
+ (void)removeALlObjectsInContext:(NSManagedObjectContext *)context;

- (id)getPrimitiveValueForKey:(NSString *)key;
- (void)changePrimitiveValue:(id)value forKey:(NSString *)key;

@end
