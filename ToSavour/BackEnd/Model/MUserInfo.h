//
//  MUserInfo.h
//  ToSavour
//
//  Created by Jason Wan on 11/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MUserInfo : NSManagedObject

@property (nonatomic, retain) NSString * fbBirthday;
@property (nonatomic, retain) NSString * fbFirstName;
@property (nonatomic, retain) NSString * fbId;
@property (nonatomic, retain) NSString * fbLastName;
@property (nonatomic, retain) NSString * fbLink;
@property (nonatomic, retain) NSString * fbMiddleName;
@property (nonatomic, retain) NSString * fbName;
@property (nonatomic, retain) NSString * fbUsername;

+ (id)newUserInfoInContext:(NSManagedObjectContext *)context;
+ (id)currentUserInfoInContext:(NSManagedObjectContext *)context;

@end
