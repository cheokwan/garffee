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


@interface MUserInfo : NSManagedObject<RKMappableEntity, RKFacebookMappableEntity>

@property (nonatomic, retain) NSNumber * fbAgeRangeMin;
@property (nonatomic, retain) NSDate * fbBirthday;
@property (nonatomic, retain) NSString * fbEmail;
@property (nonatomic, retain) NSString * fbFirstName;
@property (nonatomic, retain) NSString * fbGender;
@property (nonatomic, retain) NSString * fbID;
@property (nonatomic, retain) NSString * fbLastName;
@property (nonatomic, retain) NSString * fbLink;
@property (nonatomic, retain) NSString * fbMiddleName;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * fbProfilePicURL;
@property (nonatomic, retain) NSString * fbUsername;
@property (nonatomic, retain) NSString * tsFirstName;
@property (nonatomic, retain) NSString * tsLastName;
@property (nonatomic, retain) NSNumber * tsCreditBalance;
@property (nonatomic, retain) NSString * tsEmail;
@property (nonatomic, retain) NSString * tsGender;
@property (nonatomic, retain) NSDate * tsBirthday;
@property (nonatomic, retain) NSString * tsPhoneNumber;
@property (nonatomic, retain) NSString * tsProfileImageURL;
@property (nonatomic, retain) NSString * tsID;
@property (nonatomic, retain) NSDate * tsUserCreationDate;
@property (nonatomic, retain) NSDate * tsUserLastUpdatedDate;
@property (nonatomic, retain) NSNumber * tsCoffeeIconID;

+ (id)newUserInfoInContext:(NSManagedObjectContext *)context;
+ (id)currentUserInfoInContext:(NSManagedObjectContext *)context;

+ (RKEntityMapping *)facebookEntityMapping;
+ (RKEntityMapping *)appEntityMapping;
+ (RKEntityMapping *)appUserCreationEntityMapping;
+ (RKResponseDescriptor *)facebookResponseDescriptor;
+ (RKResponseDescriptor *)appResponseDescriptor;

@end
