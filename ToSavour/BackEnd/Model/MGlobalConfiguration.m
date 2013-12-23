//
//  MGlobalConfiguration.m
//  ToSavour
//
//  Created by Jason Wan on 21/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MGlobalConfiguration.h"
#import "RestManager.h"


@implementation MGlobalConfiguration

@dynamic id;
@dynamic key;
@dynamic lastUpdatedDateTime;
@dynamic value;

+ (MGlobalConfiguration *)configurationWithKey:(NSString *)key inContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [self fetchRequestInContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key = %@", key];
    fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DDLogError(@"error fetching global configuration with key %@: %@", key, error);
    }
    return results.count > 0 ? results[0] : nil;
}

+ (NSString *)cachedBlobHostName {
    static NSString *hostName = nil;
    if (!hostName) {
        NSAssert([NSThread currentThread] == [NSThread mainThread], @"must popuate the cache in main thread");
        MGlobalConfiguration *config = [self configurationWithKey:M_GLOBAL_CONFIGURATION_BLOBHOSTNAME inContext:[AppDelegate sharedAppDelegate].managedObjectContext];
        hostName = config.value;
    }
    return hostName;
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                    @"id",
                                                  @"Key":                   @"key",
                                                  @"Value":                 @"value",
                                                  @"LastUpdatedDateTime":   @"lastUpdatedDateTime"
                                                  }];
    mapping.identificationAttributes = @[@"id"];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"id:%@, "
            @"key:%@, "
            @"value:%@, "
            @"lastUpdatedDateTime:%@, ",
            self.id,
            self.key,
            self.value,
            self.lastUpdatedDateTime];
}

@end
