//
//  MProductConfigurableOption.h
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MProductInfo, MProductOptionChoice;

@interface MProductConfigurableOption : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sequence;
@property (nonatomic, retain) NSNumber * defaultChoice;
@property (nonatomic, retain) NSOrderedSet *choices;
@property (nonatomic, retain) MProductInfo *product;
@end

@interface MProductConfigurableOption (CoreDataGeneratedAccessors)

- (void)insertObject:(MProductOptionChoice *)value inChoicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChoicesAtIndex:(NSUInteger)idx;
- (void)insertChoices:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChoicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChoicesAtIndex:(NSUInteger)idx withObject:(MProductOptionChoice *)value;
- (void)replaceChoicesAtIndexes:(NSIndexSet *)indexes withChoices:(NSArray *)values;
- (void)addChoicesObject:(MProductOptionChoice *)value;
- (void)removeChoicesObject:(MProductOptionChoice *)value;
- (void)addChoices:(NSOrderedSet *)values;
- (void)removeChoices:(NSOrderedSet *)values;

@end
