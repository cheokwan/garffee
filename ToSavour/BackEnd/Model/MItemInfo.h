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

@class MItemSelectedOption, MOrderInfo, MProductInfo;

@interface MItemInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * productID;
@property (nonatomic, retain) NSNumber * couponID;
@property (nonatomic, retain) NSNumber * orderID;
@property (nonatomic, retain) NSSet *itemSelectedOptions;
@property (nonatomic, retain) MProductInfo *product;
@property (nonatomic, retain) MOrderInfo *order;

+ (id)newItemInfoWithProduct:(MProductInfo *)product optionChoices:(NSArray *)choices inContext:(NSManagedObjectContext *)context;
- (void)updatePrice;
@end

@interface MItemInfo (CoreDataGeneratedAccessors)

- (void)addItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)removeItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)addItemSelectedOptions:(NSSet *)values;
- (void)removeItemSelectedOptions:(NSSet *)values;

@end
