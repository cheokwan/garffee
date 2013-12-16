//
//  MProductInfo.m
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductInfo.h"
#import "MProductConfigurableOption.h"


@implementation MProductInfo

@dynamic id;
@dynamic name;
@dynamic type;
@dynamic category;
@dynamic imageURL;
@dynamic configurableOptions;

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                  @"name": @"name",
                                                  @"type": @"type",
                                                  @"category": @"category",
                                                  @"imageURL": @"imageURL"}];
    mapping.identificationAttributes = @[@"id"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
