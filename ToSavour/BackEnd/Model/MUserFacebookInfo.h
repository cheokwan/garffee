//
//  MUserFacebookInfo.h
//  ToSavour
//
//  Created by Jason Wan on 31/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MUserInfo.h"

@interface MUserFacebookInfo : MUserInfo

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
@property (nonatomic, retain) NSString * fbProfileImageURL;
@property (nonatomic, retain) NSString * fbUsername;

+ (RKEntityMapping *)appUserCreationEntityMapping;
+ (RKResponseDescriptor *)fetchFriendsResponseDescriptor;

@end
