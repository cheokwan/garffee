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

- (NSString *)firstName {
    return self.abFirstName;  // XXXXX
}

- (NSString *)lastName {
    return self.abLastName;  // XXXXX
}

- (NSDate *)birthday {
    return self.abBirthday;  // XXXXX
}

- (NSString *)phoneNumber {
    return self.abPhoneNumber;  // XXXXX
}

- (NSString *)email {
    return self.abEmail;  // XXXXX
}

- (NSString *)profileImageURL {
    return self.abProfileImageURL;  // XXXXX
}

- (NSURL *)URLForProfileImage {
    if (self.abProfileImageURL) {
        return [NSURL fileURLWithPath:self.abProfileImageURL isDirectory:NO];  // XXXXX
    } else {
        return nil;
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
