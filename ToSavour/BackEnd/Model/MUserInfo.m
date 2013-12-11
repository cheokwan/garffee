//
//  MUserInfo.m
//  ToSavour
//
//  Created by Jason Wan on 11/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MUserInfo.h"
#import "NSManagedObject+Helper.h"


@implementation MUserInfo

@dynamic fbBirthday;
@dynamic fbFirstName;
@dynamic fbId;
@dynamic fbLastName;
@dynamic fbLink;
@dynamic fbMiddleName;
@dynamic fbName;
@dynamic fbUsername;

+ (id)newUserInfoInContext:(NSManagedObjectContext *)context {
    [self.class removeALlObjectsInContext:context];
    return (MUserInfo *)[self.class newObjectInContext:context];
}

+ (id)currentUserInfoInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self.class fetchRequestInContext:context];
    NSError *error = nil;
    NSArray *allUserInfo = [context executeFetchRequest:request error:&error];
    if (error) {
        DDLogError(@"unable to fetch user info: %@", error);
        return nil;
    }
    if (allUserInfo.count == 0) {
        DDLogWarn(@"no user info exists, unexpected if the user has already signed in");
        return nil;
    }
    if (allUserInfo.count > 1) {
        DDLogWarn(@"more than one user info exists: %d, unexpected", allUserInfo.count);
    }
    return allUserInfo[0];
}

@end
