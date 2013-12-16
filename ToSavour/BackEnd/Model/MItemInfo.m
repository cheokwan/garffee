//
//  MItemInfo.m
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MItemInfo.h"
#import "MItemSelectedOption.h"
#import "MProductInfo.h"


@implementation MItemInfo

@dynamic id;
@dynamic price;
@dynamic status;
@dynamic createdDateTime;
@dynamic product;
@dynamic itemSelectedOptions;

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"id": @"id",
                                                  @"price": @"price",
                                                  @"status": @"status",
                                                  @"createdDateTime": @"createdDateTime"}];
    mapping.identificationAttributes = @[@"id"];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
