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
- (void)deleteInContext:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context;
+ (void)removeALlObjectsInContext:(NSManagedObjectContext *)context;

@end
