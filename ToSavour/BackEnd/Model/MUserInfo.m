//
//  MUserInfo.m
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MUserInfo.h"
#import "NSManagedObject+Helper.h"
#import "RestManager.h"
//#import <BlocksKit/BlocksKit.h>  XXX-BUG has build issues


@implementation MUserInfo

@dynamic fbAgeRangeMin;
@dynamic fbBirthday;
@dynamic fbEmail;
@dynamic fbFirstName;
@dynamic fbGender;
@dynamic fbID;
@dynamic fbLastName;
@dynamic fbLink;
@dynamic fbMiddleName;
@dynamic fbName;
@dynamic fbProfilePicURL;
@dynamic fbUsername;
@dynamic tsFirstName;
@dynamic tsLastName;
@dynamic tsCreditBalance;
@dynamic tsEmail;
@dynamic tsGender;
@dynamic tsBirthday;
@dynamic tsPhoneNumber;
@dynamic tsProfileImageURL;
@dynamic tsID;
@dynamic tsUserCreationDate;
@dynamic tsUserLastUpdatedDate;
@dynamic tsCoffeeIconID;

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
    return [self.class appEntityMapping];
}

+ (RKEntityMapping *)facebookEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id":                @"fbID",
                                                  @"name":              @"fbName",
                                                  @"username":          @"fbUsername",
                                                  @"email":             @"fbEmail",
                                                  @"first_name":        @"fbFirstName",
                                                  @"middle_name":       @"fbMiddleName",
                                                  @"last_name":         @"fbLastName",
                                                  @"gender":            @"fbGender",
                                                  @"age_range.min":     @"fbAgeRangeMin",
                                                  @"link":              @"fbLink",
                                                  @"birthday":          @"fbBirthday",
                                                  @"picture.data.url":  @"fbProfilePicURL"
                                                  }];
    mapping.identificationAttributes = @[@"fbID"];
    return mapping;
}

+ (RKEntityMapping *)appEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"tsID",
                                                  @"FacebookId":        @"fbID",
                                                  @"FirstName":         @"tsFirstName",
                                                  @"LastName":          @"tsLastName",
                                                  @"CreditBalance":     @"tsCreditBalance",
                                                  @"Email":             @"tsEmail",
                                                  @"Sex":               @"tsGender",
                                                  @"Birthday":          @"tsBirthday",
                                                  @"Phone":             @"tsPhoneNumber",
                                                  @"ProfileImageUrl":   @"tsProfileImageURL",
                                                  @"CreatedDateTime":   @"tsUserCreationDate",
                                                  @"LastUpdatedDateTime": @"tsUserLastUpdatedDate",
                                                  @"CoffeeIconId":      @"tsCoffeeIconID"}];
    mapping.identificationAttributes = @[@"tsID", @"fbID"];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKEntityMapping *)appUserCreationEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"FacebookId": @"fbID",
                                                  @"FirstName": @"fbFirstName",
                                                  @"LastName": @"fbLastName",
//                                                  @"CreditBalance": @"",
                                                  @"Email": @"fbEmail",
                                                  @"Sex": @"fbGender",
                                                  @"Birthday": @"fbBirthday",
//                                                  @"Phone": @"",
                                                  @"ProfileImageUrl": @"fbProfilePicURL",
//                                                  @"CreatedDateTime": @"",
//                                                  @"LastUpdatedDateTime": @"",
//                                                  @"CoffeeIconID": @"",
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return [mapping inverseMapping];
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [self.class appResponseDescriptor];
}

+ (RKResponseDescriptor *)facebookResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class facebookEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+ (RKResponseDescriptor *)appResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class appEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"fbID:%@, "
            @"fbEmail:%@, "
            @"fbBirthday:%@, "
            @"fbFirstName:%@, "
            @"fbLastName:%@, "
            @"fbLink:%@, "
            @"fbMiddleName:%@, "
            @"fbName:%@, "
            @"fbProfilePicURL:%@, "
            @"fbUsername:%@, "
            @"fbAgeRangeMin:%@, "
            @"fbGender:%@, "
            @"tsFirstName:%@, "
            @"tsLastName:%@, "
            @"tsCreditBalance:%@, "
            @"tsEmail:%@, "
            @"tsGender:%@, "
            @"tsBirthday:%@, "
            @"tsPhoneNumber:%@, "
            @"tsProfileImageURL:%@, "
            @"tsID:%@, "
            @"tsUserCreationDate:%@, "
            @"tsUserLastUpdatedDate:%@, "
            @"tsCoffeeIconID:%@, ",
            self.fbID,
            self.fbEmail,
            self.fbBirthday,
            self.fbFirstName,
            self.fbLastName,
            self.fbLink,
            self.fbMiddleName,
            self.fbName,
            self.fbProfilePicURL,
            self.fbUsername,
            self.fbAgeRangeMin,
            self.fbGender,
            self.tsFirstName,
            self.tsLastName,
            self.tsCreditBalance,
            self.tsEmail,
            self.tsGender,
            self.tsBirthday,
            self.tsPhoneNumber,
            self.tsProfileImageURL,
            self.tsID,
            self.tsUserCreationDate,
            self.tsUserLastUpdatedDate,
            self.tsCoffeeIconID
            ];
}

@end
