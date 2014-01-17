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
@dynamic fbProfileImageURL;
@dynamic fbUsername;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.userType = @(MUserInfoUserTypeFacebookUser);
}

- (void)setFbID:(NSString *)fbID {
    [self changeValue:fbID forKey:@"fbID"];
}

- (void)setFbFirstName:(NSString *)fbFirstName {
    [self changeValue:fbFirstName forKey:@"fbFirstName"];
}

- (void)setFbLastName:(NSString *)fbLastName {
    [self changeValue:fbLastName forKey:@"fbLastName"];
}

- (void)setFbBirthday:(NSDate *)fbBirthday {
    [self changeValue:fbBirthday forKey:@"fbBirthday"];
}

- (void)setFbEmail:(NSString *)fbEmail {
    [self changeValue:fbEmail forKey:@"fbEmail"];
}

- (void)setFbGender:(NSString *)fbGender {
    [self changeValue:fbGender forKey:@"fbGender"];
}

- (void)setFbName:(NSString *)fbName {
    [self changeValue:fbName forKey:@"fbName"];
}

- (void)setFbProfileImageURL:(NSString *)fbProfileImageURL {
    [self changeValue:fbProfileImageURL forKey:@"fbProfileImageURL"];
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [super changeValue:value forKey:key];
    if ([self.appID trimmedWhiteSpaces].length > 0) {
        return;
    }
    if ([key isEqualToString:@"fbID"]) {
        self.facebookID = self.fbID;
    } else if ([key isEqualToString:@"fbFirstName"]) {
        self.firstName = self.fbFirstName;
    } else if ([key isEqualToString:@"fbLastName"]) {
        self.lastName = self.fbLastName;
    } else if ([key isEqualToString:@"fbBirthday"]) {
        self.birthday = self.fbBirthday;
    } else if ([key isEqualToString:@"fbEmail"]) {
        self.email = self.fbEmail;
    } else if ([key isEqualToString:@"fbGender"]) {
        self.gender = self.fbGender;
    } else if ([key isEqualToString:@"fbName"]) {
        self.name = self.fbName;
    } else if ([key isEqualToString:@"fbProfileImageURL"]) {
        self.profileImageURL = self.fbProfileImageURL;
    }
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
                                                  @"picture.data.url":  @"fbProfileImageURL"
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
                                                  @"ProfileImageUrl":   @"fbProfileImageURL",
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
                             @"fbProfileImageURL:%@, "
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
                             self.fbProfileImageURL,
                             self.fbLink
                             ]];
}

@end
