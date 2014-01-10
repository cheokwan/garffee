//
//  MUserInfo.h
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"


typedef enum {
    MUserInfoUserTypeUndefined          = 0,
    MUserInfoUserTypeAppNativeUser      = 1 << 0,
    MUserInfoUserTypeFacebookUser       = 1 << 1,
    MUserInfoUserTypeAddressBookUser    = 1 << 2
} MUserInfoUserType;

static NSString *MUserInfoGenderMale = @"male";
static NSString *MUserInfoGenderFemale = @"female";


@interface MUserInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSString * appID;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * coffeeIconID;
@property (nonatomic, retain) NSNumber * creditBalance;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * isAppUser;
@property (nonatomic, retain) NSNumber * isDirty;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSDate * userCreationDate;
@property (nonatomic, retain) NSDate * userLastUpdatedDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * userType;

@property (nonatomic, readonly) NSURL *URLForProfileImage;


+ (id)newAppUserInfoInContext:(NSManagedObjectContext *)context;
+ (id)currentAppUserInfoInContext:(NSManagedObjectContext *)context;

- (void)changeValue:(id)value forKey:(NSString *)key;

@end
