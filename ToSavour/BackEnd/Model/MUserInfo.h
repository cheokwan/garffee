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


@interface MUserInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t fbAgeRangeMin;
@property (nonatomic, retain) NSString * fbBirthday;
@property (nonatomic, retain) NSString * fbFirstName;
@property (nonatomic, retain) NSString * fbGender;
@property (nonatomic) int32_t fbID;
@property (nonatomic, retain) NSString * fbLastName;
@property (nonatomic, retain) NSString * fbLink;
@property (nonatomic, retain) NSString * fbMiddleName;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * fbProfilePicURL;
@property (nonatomic, retain) NSString * fbUsername;

+ (id)newUserInfoInContext:(NSManagedObjectContext *)context;
+ (id)currentUserInfoInContext:(NSManagedObjectContext *)context;

@end
