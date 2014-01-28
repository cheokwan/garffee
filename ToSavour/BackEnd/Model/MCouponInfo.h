//
//  MCouponInfo.h
//  ToSavour
//
//  Created by Jason Wan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MItemInfo, MUserInfo;

@interface MCouponInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * receiverUserID;
@property (nonatomic, retain) NSDate * redeemedDate;
@property (nonatomic, retain) NSString * referenceCode;
@property (nonatomic, retain) NSString * senderUserID;
@property (nonatomic, retain) NSString * sponsorName;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) MUserInfo *receiver;
@property (nonatomic, retain) MUserInfo *sender;

@property (nonatomic, readonly) NSURL *URLForImageRepresentation;

- (NSString *)issuerName;

@end

@interface MCouponInfo (CoreDataGeneratedAccessors)

- (void)addItemsObject:(MItemInfo *)value;
- (void)removeItemsObject:(MItemInfo *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end