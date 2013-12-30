//
//  MItemSelectedOption.h
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MItemInfo, MProductOptionChoice;

@interface MItemSelectedOption : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * itemID;
@property (nonatomic, retain) NSNumber * optionChoiceID;
@property (nonatomic, retain) MItemInfo *item;
@property (nonatomic, retain) MProductOptionChoice *productOptionChoice;

+ (id)newItemSelectedOptionWithOptionChoice:(MProductOptionChoice *)choice inContext:(NSManagedObjectContext *)context;

@end
