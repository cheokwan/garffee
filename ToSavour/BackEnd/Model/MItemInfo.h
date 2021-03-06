//
//  MItemInfo.h
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MCouponInfo, MItemSelectedOption, MOrderInfo, MProductInfo;

@interface MItemInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * couponID;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * orderID;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * productID;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) MCouponInfo *coupon;
@property (nonatomic, retain) NSSet *itemSelectedOptions;
@property (nonatomic, retain) MOrderInfo *order;
@property (nonatomic, retain) MProductInfo *product;

@property (nonatomic, readonly) NSString *detailString;

+ (id)newItemInfoWithProduct:(MProductInfo *)product optionChoices:(NSArray *)choices inContext:(NSManagedObjectContext *)context;
- (void)deleteAllSelectedOptions;
- (void)addOptionChoices:(NSArray *)choices;
- (void)updatePrice;
@end

@interface MItemInfo (CoreDataGeneratedAccessors)

- (void)addItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)removeItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)addItemSelectedOptions:(NSSet *)values;
- (void)removeItemSelectedOptions:(NSSet *)values;

@end
