//
//  MProductConfigurableOption.m
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductConfigurableOption.h"


@implementation MProductConfigurableOption

@dynamic id;
@dynamic name;
@dynamic sequence;
@dynamic product;
@dynamic defaultChoice;
@dynamic choices;

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                  @"name": @"name",
                                                  @"sequence": @"sequence"}];
    mapping.identificationAttributes = @[@"id"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
