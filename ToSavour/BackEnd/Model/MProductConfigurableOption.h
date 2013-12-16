//
//  MProductConfigurableOption.h
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"


@interface MProductConfigurableOption : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) int32_t sequence;
@property (nonatomic, retain) NSManagedObject *product;
@property (nonatomic, retain) NSManagedObject *defaultChoice;
@property (nonatomic, retain) NSSet *choices;
@end

@interface MProductConfigurableOption (CoreDataGeneratedAccessors)

- (void)addChoicesObject:(NSManagedObject *)value;
- (void)removeChoicesObject:(NSManagedObject *)value;
- (void)addChoices:(NSSet *)values;
- (void)removeChoices:(NSSet *)values;

@end
