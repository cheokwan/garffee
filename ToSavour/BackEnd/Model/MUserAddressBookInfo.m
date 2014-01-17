//
//  MUserAddressBookInfo.m
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MUserAddressBookInfo.h"


@implementation MUserAddressBookInfo

@dynamic abBirthday;
@dynamic abContactID;
@dynamic abEmail;
@dynamic abFirstName;
@dynamic abLastName;
@dynamic abPhoneNumbers;
@dynamic abProfileImageURL;
@dynamic abCanonicalPhoneNumbers;


- (NSURL *)URLForProfileImage {
    if (self.abProfileImageURL) {
        return [NSURL fileURLWithPath:self.abProfileImageURL isDirectory:NO];
    } else {
        return nil;
    }
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    self.userType = @(MUserInfoUserTypeAddressBookUser);
}

- (void)setAbFirstName:(NSString *)abFirstName {
    [self changeValue:abFirstName forKey:@"abFirstName"];
}

- (void)setAbLastName:(NSString *)abLastName {
    [self changeValue:abLastName forKey:@"abLastName"];
}

- (void)setAbBirthday:(NSDate *)abBirthday {
    [self changeValue:abBirthday forKey:@"abBirthday"];
}

- (void)setAbEmail:(NSString *)abEmail {
    [self changeValue:abEmail forKey:@"abEmail"];
}

- (void)setAbPhoneNumbers:(NSString *)abPhoneNumbers {
    [self changeValue:abPhoneNumbers forKey:@"abPhoneNumbers"];
}

- (void)setAbProfileImageURL:(NSString *)abProfileImageURL {
    [self changeValue:abProfileImageURL forKey:@"abProfileImageURL"];
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [super changeValue:value forKey:key];
    if ([self.appID trimmedWhiteSpaces].length > 0) {
        return;
    }
    if ([key isEqualToString:@"abFirstName"]) {
        self.firstName = self.abFirstName;
    } else if ([key isEqualToString:@"abLastName"]) {
        self.lastName = self.abLastName;
    } else if ([key isEqualToString:@"abBirthday"]) {
        self.birthday = self.abBirthday;
    } else if ([key isEqualToString:@"abEmail"]) {
        self.email = self.abEmail;
    } else if ([key isEqualToString:@"abPhoneNumbers"]) {
        self.phoneNumber = self.abPhoneNumbers;
    } else if ([key isEqualToString:@"abProfileImageURL"]) {
        self.profileImageURL = self.abProfileImageURL;
    }
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromArray:@[@"abBirthday",
                                             @"abEmail",
                                             @"abFirstName",
                                             @"abLastName",
                                             @"abPhoneNumbers",
                                             @"abProfileImageURL",
                                             @"abContactID",
                                             ]];
    mapping.identificationAttributes = @[@"abContactID"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [[super description] stringByAppendingString:[NSString stringWithFormat:
            @"abContactID:%@, "
            @"abFirstName:%@, "
            @"abLastName:%@, "
            @"abBirthday:%@, "
            @"abPhoneNumbers:%@, "
            @"abCanonicalPhoneNumbers:%@, "
            @"abEmail:%@, "
            @"abProfileImageURL:%@, ",
            self.abContactID,
            self.abFirstName,
            self.abLastName,
            self.abBirthday,
            self.abPhoneNumbers,
            self.abCanonicalPhoneNumbers,
            self.abEmail,
            self.abProfileImageURL
            ]];
}

@end
