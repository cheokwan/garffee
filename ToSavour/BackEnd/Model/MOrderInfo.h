//
//  MOrderInfo.h
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MItemInfo;

static NSString *MOrderInfoStatusInCart     = @"InCart";
static NSString *MOrderInfoStatusSubmitted  = @"Submitted";
static NSString *MOrderInfoStatusPending    = @"Pending";
static NSString *MOrderInfoStatusInProgress = @"Inprogress";
static NSString *MOrderInfoStatusFinished   = @"Finished";
static NSString *MOrderInfoStatusPickedUp   = @"Pickedup";


@interface MOrderInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * orderedDate;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * pickupTime;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSDate * expectedArrivalTime;
@property (nonatomic, retain) NSString * referenceNumber;
@property (nonatomic, retain) NSNumber * storeBranchID;
@property (nonatomic, retain) NSSet *items;

+ (MOrderInfo *)newOrderInfoInContext:(NSManagedObjectContext *)context;
- (void)updatePrice;
@end

@interface MOrderInfo (CoreDataGeneratedAccessors)

- (void)addItemsObject:(MItemInfo *)value;
- (void)removeItemsObject:(MItemInfo *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
