//
//  MProductOptionChoice.m
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductOptionChoice.h"
#import "MProductConfigurableOption.h"
#import "RestManager.h"
#import "MGlobalConfiguration.h"


@implementation MProductOptionChoice

@dynamic id;
@dynamic imageURL;
@dynamic name;
@dynamic price;
@dynamic productConfigurableOption;

- (NSString *)resolvedImageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.imageURL];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":        @"id",
                                                  @"Name":      @"name",
                                                  @"Price":     @"price",
                                                  @"ImageUrl":  @"imageURL"}];
    mapping.identificationAttributes = @[@"id"];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"id:%@ "
            @"name:%@ "
            @"price:%@ "
            @"imageUrl:%@ ",
            self.id,
            self.name,
            self.price,
            self.imageURL];
}

@end
