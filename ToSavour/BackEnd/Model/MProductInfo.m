//
//  MProductInfo.m
//  ToSavour
//
//  Created by Jason Wan on 16/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductInfo.h"
#import "MProductConfigurableOption.h"
#import "RestManager.h"
#import "MGlobalConfiguration.h"


@implementation MProductInfo

@dynamic id;
@dynamic name;
@dynamic type;
@dynamic category;
@dynamic imageURL;
@dynamic configurableOptions;

- (NSString *)resolvedImageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.imageURL];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":        @"id",
                                                  @"Name":      @"name",
                                                  @"Type":      @"type",
                                                  @"Category":  @"category",
                                                  @"ImageUrl":  @"imageURL"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ProductConfigurableOptions" toKeyPath:@"configurableOptions" withMapping:[MProductConfigurableOption defaultEntityMapping]]];
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
            @"type:%@ "
            @"category:%@ "
            @"imageURL:%@ ",
            self.id,
            self.name,
            self.type,
            self.category,
            self.imageURL];
}

@end
