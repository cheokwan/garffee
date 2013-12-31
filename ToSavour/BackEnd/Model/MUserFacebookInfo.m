//
//  MUserFacebookInfo.m
//  ToSavour
//
//  Created by Jason Wan on 31/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MUserFacebookInfo.h"
#import "RestManager.h"


@implementation MUserFacebookInfo

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


- (NSDate *)birthday {
    return self.fbBirthday; // XXXXX
}

- (NSString *)email {
    return self.fbEmail; // XXXXX
}

- (NSString *)firstName {
    return self.fbFirstName; // XXXXX
}

- (NSString *)lastName {
    return self.fbLastName; // XXXXX
}

- (NSString *)gender {
    return self.fbGender; // XXXXX
}

- (NSString *)profileImageURL {
    return self.fbProfilePicURL; // XXXXX
}

- (NSString *)name {
    return self.fbName; // XXXXX
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
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

+ (RKEntityMapping *)appUserCreationEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"FacebookId":        @"fbID",
                                                  @"FirstName":         @"fbFirstName",
                                                  @"LastName":          @"fbLastName",
                                                  //@"CreditBalance":     @"",
                                                  @"Email":             @"fbEmail",
                                                  @"Sex":               @"fbGender",
                                                  @"Birthday":          @"fbBirthday",
                                                  //@"Phone":             @"",
                                                  @"ProfileImageUrl":   @"fbProfilePicURL",
                                                  //@"CreatedDateTime":   @"",
                                                  //@"LastUpdatedDateTime": @"",
                                                  //@"CoffeeIconID":      @"",
                                                  }];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return [mapping inverseMapping];
}

+ (RKResponseDescriptor *)fetchFriendsResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [[super description] stringByAppendingString:[NSString stringWithFormat:
                             @"fbID:%@, "
                             @"fbUsername:%@, "
                             @"fbName:%@, "
                             @"fbFirstName:%@, "
                             @"fbMiddleName:%@, "
                             @"fbLastName:%@, "
                             @"fbEmail:%@, "
                             @"fbBirthday:%@, "
                             @"fbGender:%@, "
                             @"fbAgeRangeMin:%@, "
                             @"fbProfilePicURL:%@, "
                             @"fbLink:%@, ",
                             self.fbID,
                             self.fbUsername,
                             self.fbName,
                             self.fbFirstName,
                             self.fbMiddleName,
                             self.fbLastName,
                             self.fbEmail,
                             self.fbBirthday,
                             self.fbGender,
                             self.fbAgeRangeMin,
                             self.fbProfilePicURL,
                             self.fbLink
                             ]];
}

@end
