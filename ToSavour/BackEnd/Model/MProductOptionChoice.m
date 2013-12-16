//
//  MProductOptionChoice.m
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductOptionChoice.h"
#import "MProductConfigurableOption.h"


@implementation MProductOptionChoice

@dynamic id;
@dynamic name;
@dynamic price;
@dynamic imageURL;
@dynamic productConfigurableOption;

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                  @"name": @"name",
                                                  @"price": @"price",
                                                  @"imageURL": @"imageURL"}];
    mapping.identificationAttributes = @[@"id"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
