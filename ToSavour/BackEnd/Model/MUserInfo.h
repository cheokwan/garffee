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

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSNumber * coffeeIconID;
@property (nonatomic, retain) NSNumber * creditBalance;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * appID;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSDate * userCreationDate;
@property (nonatomic, retain) NSDate * userLastUpdatedDate;
@property (nonatomic, retain) NSNumber * isDirty;
@property (nonatomic, retain) NSString * facebookID;
@property (nonatomic, retain) NSNumber * isAppUser;

@property (nonatomic, readonly) NSString * name;
@property (nonatomic, readonly) NSURL *URLForProfileImage;


+ (id)newAppUserInfoInContext:(NSManagedObjectContext *)context;
+ (id)currentAppUserInfoInContext:(NSManagedObjectContext *)context;

@end
