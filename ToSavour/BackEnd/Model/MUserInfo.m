//
//  MUserInfo.m
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MUserInfo.h"
#import "RestManager.h"


@implementation MUserInfo

@dynamic birthday;
@dynamic coffeeIconID;
@dynamic creditBalance;
@dynamic email;
@dynamic firstName;
@dynamic gender;
@dynamic appID;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic profileImageURL;
@dynamic userCreationDate;
@dynamic userLastUpdatedDate;
@dynamic isDirty;
@dynamic facebookID;
@dynamic isAppUser;


+ (id)newAppUserInfoInContext:(NSManagedObjectContext *)context {
    MUserInfo *currentUser = [self.class currentAppUserInfoInContext:context];
    if (currentUser) {
        [context deleteObject:currentUser];
    }
    currentUser = (MUserInfo *)[self.class newObjectInContext:context];
    currentUser.isAppUser = @YES;
    return currentUser;
}

+ (id)currentAppUserInfoInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [MUserInfo fetchRequestInContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isAppUser = %@", @YES];
    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"unable to fetch app user info: %@", error);
        return nil;
    }
    if (fetchResults.count == 0) {
        DDLogWarn(@"no user info exists, unexpected if the user has already signed in");
        return nil;
    }
    if (fetchResults.count > 1) {
        DDLogWarn(@"more than one user info exists, unexpected, keeping only the first: %@", fetchResults);
        for (NSManagedObject *userObject in fetchResults) {
            if (userObject != [fetchResults firstObject]) {
                [context deleteObject:userObject];
            }
        }
    }
    return fetchResults[0];
}

- (NSString *)name {
    return [[NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName] trimmedWhiteSpaces];
}

- (NSURL *)URLForProfileImage {
    if (self.profileImageURL) {
        return [NSURL URLWithString:self.profileImageURL];  // XXXXX
    } else {
        return nil;
    }
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"appID",
                                                  @"FacebookId":        @"facebookID",
                                                  @"FirstName":         @"firstName",
                                                  @"LastName":          @"lastName",
                                                  @"CreditBalance":     @"creditBalance",
                                                  @"Email":             @"email",
                                                  @"Sex":               @"gender",
                                                  @"Birthday":          @"birthday",
                                                  @"Phone":             @"phoneNumber",
                                                  @"ProfileImageUrl":   @"profileImageURL",
                                                  @"CreatedDateTime":   @"userCreationDate",
                                                  @"LastUpdatedDateTime": @"userLastUpdatedDate",
                                                  @"CoffeeIconId":      @"coffeeIconID"}];
    mapping.identificationAttributes = @[@"appID", @"facebookID"];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"appID:%@, "
            @"facebookID:%@, "
            @"firstName:%@, "
            @"lastName:%@, "
            @"creditBalance:%@, "
            @"email:%@, "
            @"gender:%@, "
            @"birthday:%@, "
            @"phoneNumber:%@, "
            @"profileImageURL:%@, "
            @"userCreationDate:%@, "
            @"userLastUpdatedDate:%@, "
            @"coffeeIconID:%@, "
            @"isAppUser:%@, "
            @"isDirty:%@, ",
            self.appID,
            self.facebookID,
            self.firstName,
            self.lastName,
            self.creditBalance,
            self.email,
            self.gender,
            self.birthday,
            self.phoneNumber,
            self.profileImageURL,
            self.userCreationDate,
            self.userLastUpdatedDate,
            self.coffeeIconID,
            self.isAppUser,
            self.isDirty
            ];
}

@end
