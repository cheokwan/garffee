//
//  MUserAddressBookInfo.h
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MUserInfo.h"


@interface MUserAddressBookInfo : MUserInfo

@property (nonatomic, retain) NSDate * abBirthday;
@property (nonatomic, retain) NSNumber * abContactID;
@property (nonatomic, retain) NSString * abEmail;
@property (nonatomic, retain) NSString * abFirstName;
@property (nonatomic, retain) NSString * abLastName;
@property (nonatomic, retain) NSString * abPhoneNumbers;
@property (nonatomic, retain) NSString * abProfileImageURL;
@property (nonatomic, retain) NSString * abCanonicalPhoneNumbers;

@end
