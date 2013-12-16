//
//  MItemSelectedOption.h
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MItemInfo;

@interface MItemSelectedOption : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t id;
@property (nonatomic, retain) MItemInfo *item;
@property (nonatomic, retain) NSManagedObject *productOptionChoice;

@end
