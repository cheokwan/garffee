//
//  MUserAddressBookInfo.m
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MUserAddressBookInfo.h"


@implementation MUserAddressBookInfo

@dynamic abFirstName;
@dynamic abLastName;
@dynamic abBirthday;
@dynamic abPhoneNumber;
@dynamic abEmail;
@dynamic abProfileImageURL;


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

- (void)setAbPhoneNumber:(NSString *)abPhoneNumber {
    [self changeValue:abPhoneNumber forKey:@"abPhoneNumber"];
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
    } else if ([key isEqualToString:@"abPhoneNumber"]) {
        self.phoneNumber = self.abPhoneNumber;
    } else if ([key isEqualToString:@"abProfileImageURL"]) {
        self.profileImageURL = self.abProfileImageURL;
    }
}

- (NSString *)description {
    return [[super description] stringByAppendingString:[NSString stringWithFormat:
            @"abFirstName:%@, "
            @"abLastName:%@, "
            @"abBirthday:%@, "
            @"abPhoneNumber:%@, "
            @"abEmail:%@, ",
            self.abFirstName,
            self.abLastName,
            self.abBirthday,
            self.abPhoneNumber,
            self.abEmail
            ]];
}

@end
