//
//  MockData.m
//  ToSavour
//
//  Created by LAU Leung Yan on 6/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

//  IMPORTANT: THIS CLASS IS EXCLUSIVELY USED TO DEBUG
//  NEED TO BE REMOVED FOR PRODUCTION

#import "MockData.h"

#import "NSManagedObject+Helper.h"

#import "MBranch.h"

@implementation MockData

+ (void)mockBranches {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    for (int i=0; i<20; i++) {
        MBranch *branch = [MBranch newObjectInContext:context];
        branch.name = [NSString stringWithFormat:@"Branch %d", i];
        branch.thumbnailURL = @"http://www.cartype.com/pics/1627/full/maserati_tridente.jpg";
        branch.openTime = @"0900";
        branch.closeTime = @"2200";
        long number = arc4random() % 100000000 + 10000000;
        branch.phoneNumber = [NSString stringWithFormat:@"%ld", number];
    }
}

+ (void)removeAllBranches {
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    NSFetchRequest *fetchRequest = [MBranch fetchRequest];
    fetchRequest.sortDescriptors = @[];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    NSError *error = nil;
    [frc performFetch:&error];
    for (MBranch *branch in frc.fetchedObjects) {
        [branch deleteInContext:context];
    }
}

@end
