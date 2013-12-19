//
//  MUserInfo.m
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MUserInfo.h"
#import "NSManagedObject+Helper.h"
//#import <BlocksKit/BlocksKit.h>  XXX-BUG has build issues


@implementation MUserInfo

@dynamic fbBirthday;
@dynamic fbFirstName;
@dynamic fbID;
@dynamic fbLastName;
@dynamic fbLink;
@dynamic fbMiddleName;
@dynamic fbName;
@dynamic fbProfilePicURL;
@dynamic fbUsername;
@dynamic fbAgeRangeMin;
@dynamic fbGender;

+ (id)newUserInfoInContext:(NSManagedObjectContext *)context {
    [self.class removeALlObjectsInContext:context];
    return (MUserInfo *)[self.class newObjectInContext:context];
}

+ (id)currentUserInfoInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self.class fetchRequestInContext:context];
    request.includesPropertyValues = YES;
    NSError *error = nil;
    NSArray *allUserInfo = [context executeFetchRequest:request error:&error];
//    allUserInfo = [allUserInfo bk_select:^BOOL(id obj) {
//        return (((NSObject *)obj).class == self.class);
//    }];  XXX-BUG has build issues
    NSMutableArray *filteredAllUserInfo = [NSMutableArray array];
    for (NSObject *obj in allUserInfo) {
        if (obj.class == self.class) {
            [filteredAllUserInfo addObject:obj];
        }
    }
    allUserInfo = filteredAllUserInfo;
    // XXX-FIX condense this
    
    if (error) {
        DDLogError(@"unable to fetch user info: %@", error);
        return nil;
    }
    if (allUserInfo.count == 0) {
        DDLogWarn(@"no user info exists, unexpected if the user has already signed in");
        return nil;
    }
    if (allUserInfo.count > 1) {
        DDLogWarn(@"more than one user info exists: %ud, unexpected", allUserInfo.count);
    }
    return allUserInfo[0];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"fbID",
                                                  @"name": @"fbName",
                                                  @"username": @"fbUsername",
                                                  @"first_name": @"fbFirstName",
                                                  @"middle_name": @"fbMiddleName",
                                                  @"last_name": @"fbLastName",
                                                  @"gender": @"fbGender",
                                                  @"age_range.min": @"fbAgeRangeMin",
                                                  @"link": @"fbLink",
                                                  @"birthday": @"fbBirthday",
                                                  @"picture.data.url": @"fbProfilePicURL"
                                                  }];
    mapping.identificationAttributes = @[@"fbID"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"fbBirthday:%@, "
            @"fbFirstName:%@, "
            @"fbID:%@, "
            @"fbLastName:%@, "
            @"fbLink:%@, "
            @"fbMiddleName:%@, "
            @"fbName:%@, "
            @"fbProfilePicURL:%@, "
            @"fbUsername:%@, "
            @"fbAgeRangeMin:%@, "
            @"fbGender:%@, ",
            self.fbBirthday,
            self.fbFirstName,
            self.fbID,
            self.fbLastName,
            self.fbLink,
            self.fbMiddleName,
            self.fbName,
            self.fbProfilePicURL,
            self.fbUsername,
            self.fbAgeRangeMin,
            self.fbGender];
}

@end
