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

@dynamic appID;
@dynamic birthday;
@dynamic coffeeIconID;
@dynamic creditBalance;
@dynamic email;
@dynamic facebookID;
@dynamic firstName;
@dynamic gender;
@dynamic isAppUser;
@dynamic isDirty;
@dynamic lastName;
@dynamic phoneNumber;
@dynamic profileImageURL;
@dynamic userCreationDate;
@dynamic userLastUpdatedDate;
@dynamic name;
@dynamic userType;


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
    NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
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
        DDLogError(@"more than one user info exists, unexpected, keeping only the first: %@", fetchResults);
        for (NSManagedObject *userObject in fetchResults) {
            if (userObject != [fetchResults firstObject]) {
                [context deleteObject:userObject];
            }
        }
    }
    return fetchResults[0];
}

- (NSURL *)URLForProfileImage {
    if (self.profileImageURL) {
        return [NSURL URLWithString:self.profileImageURL];
    } else {
        return nil;
    }
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.userType = @(MUserInfoUserTypeAppNativeUser);
}

- (void)setAppID:(NSString *)appID {
    [self changeValue:appID forKey:@"appID"];
}

- (void)setFirstName:(NSString *)firstName {
    [self changeValue:firstName forKey:@"firstName"];
}

- (void)setLastName:(NSString *)lastName {
    [self changeValue:lastName forKey:@"lastName"];
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self changePrimitiveValue:value forKey:key];
    if ([key isEqualToString:@"appID"]) {
        if ([self.appID trimmedWhiteSpaces].length > 0) {
//            self.userType = @([self.userType intValue] | MUserInfoUserTypeAppNativeUser);  // for convenience of sorting in a FRC, can't use the flag form
            self.userType = @(MUserInfoUserTypeAppNativeUser);
        }
    } else if ([key isEqualToString:@"firstName"] || [key isEqualToString:@"lastName"]) {
        self.name = [[NSString stringWithFormat:@"%@ %@", self.firstName ? self.firstName : @"", self.lastName ? self.lastName : @""] trimmedWhiteSpaces];
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
            @"userType:%@, "
            @"appID:%@, "
            @"facebookID:%@, "
            @"name:%@, "
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
            self.userType,
            self.appID,
            self.facebookID,
            self.name,
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
