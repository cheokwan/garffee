//
//  MProductOptionChoice.h
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MProductConfigurableOption;

@interface MProductOptionChoice : NSManagedObject<RKMappableEntity>

@property (nonatomic) int32_t id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic) double price;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) MProductConfigurableOption *productConfigurableOption;

@end
