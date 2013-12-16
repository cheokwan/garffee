//
//  MItemInfo.h
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MItemSelectedOption, MProductInfo;

@interface MItemInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t id;
@property (nonatomic) double price;
@property (nonatomic, retain) NSString * status;
@property (nonatomic) NSTimeInterval createdDateTime;
@property (nonatomic, retain) MProductInfo *product;
@property (nonatomic, retain) NSSet *itemSelectedOptions;
@end

@interface MItemInfo (CoreDataGeneratedAccessors)

- (void)addItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)removeItemSelectedOptionsObject:(MItemSelectedOption *)value;
- (void)addItemSelectedOptions:(NSSet *)values;
- (void)removeItemSelectedOptions:(NSSet *)values;

@end
