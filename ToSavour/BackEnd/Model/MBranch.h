//
//  MBranch.h
//  ToSavour
//
//  Created by LAU Leung Yan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"


@interface MBranch : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * branchId;
@property (nonatomic, retain) NSDate * closeTime;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * openTime;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * region;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSString * imageURL;

- (NSURL *)URLForThumbnailImage;

+ (RKEntityMapping *)defaultEntityMapping;
+ (RKResponseDescriptor *)defaultResponseDescriptor;

@end
