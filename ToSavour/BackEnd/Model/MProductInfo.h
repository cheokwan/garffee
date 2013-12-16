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

@class MProductConfigurableOption;

@interface MProductInfo : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSSet *configurableOptions;
@end

@interface MProductInfo (CoreDataGeneratedAccessors)

- (void)addConfigurableOptionsObject:(MProductConfigurableOption *)value;
- (void)removeConfigurableOptionsObject:(MProductConfigurableOption *)value;
- (void)addConfigurableOptions:(NSSet *)values;
- (void)removeConfigurableOptions:(NSSet *)values;

@end
