//
//  MProductOptionChoice.h
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"

@class MProductConfigurableOption;

@interface MProductOptionChoice : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * localCachedImageURL;
@property (nonatomic, retain) MProductConfigurableOption *productConfigurableOption;

@property (nonatomic, readonly) NSString *resolvedImageURL;
@property (nonatomic, readonly) NSURL *URLForImageRepresentation;

@end
