//
//  MProductInfo.h
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

static NSString *MProductInfoTypeReal = @"Real";
static NSString *MProductInfoTypeVirtual = @"Virtual";

@class MProductConfigurableOption;

@interface MProductInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSOrderedSet *configurableOptions;

@property (nonatomic, readonly) NSString *resolvedImageURL;
@end

@interface MProductInfo (CoreDataGeneratedAccessors)

- (void)insertObject:(MProductConfigurableOption *)value inConfigurableOptionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromConfigurableOptionsAtIndex:(NSUInteger)idx;
- (void)insertConfigurableOptions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeConfigurableOptionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInConfigurableOptionsAtIndex:(NSUInteger)idx withObject:(MProductConfigurableOption *)value;
- (void)replaceConfigurableOptionsAtIndexes:(NSIndexSet *)indexes withConfigurableOptions:(NSArray *)values;
- (void)addConfigurableOptionsObject:(MProductConfigurableOption *)value;
- (void)removeConfigurableOptionsObject:(MProductConfigurableOption *)value;
- (void)addConfigurableOptions:(NSOrderedSet *)values;
- (void)removeConfigurableOptions:(NSOrderedSet *)values;

@end
