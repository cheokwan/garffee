//
//  MGlobalConfiguration.h
//  ToSavour
//
//  Created by Jason Wan on 21/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RKMappableEntity.h"


#define M_GLOBAL_CONFIGURATION_BLOBHOSTNAME     @"BlobHostName"

@interface MGlobalConfiguration : NSManagedObject<RKMappableEntity>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSDate * lastUpdatedDateTime;
@property (nonatomic, retain) NSString * value;

+ (MGlobalConfiguration *)configurationWithKey:(NSString *)key inContext:(NSManagedObjectContext *)context;
+ (NSString *)cachedBlobHostName;

@end
