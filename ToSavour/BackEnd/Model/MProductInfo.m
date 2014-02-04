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

@dynamic category;
@dynamic id;
@dynamic imageURL;
@dynamic name;
@dynamic type;
@dynamic localCachedImageURL;
@dynamic configurableOptions;

- (NSString *)resolvedImageURL {
    return [[MGlobalConfiguration cachedBlobHostName] stringByAppendingPathComponent:self.imageURL];
}

- (NSURL *)URLForImageRepresentation {
    if (self.localCachedImageURL.length > 0) {
        return [NSURL fileURLWithPath:self.localCachedImageURL];
    } else if (self.resolvedImageURL.length > 0) {
        return [NSURL URLWithString:self.resolvedImageURL];
    }
    return nil;
}

- (NSArray *)sortedConfigurableOptions {
    NSSortDescriptor *sdSequence = [NSSortDescriptor sortDescriptorWithKey:@"sequence" ascending:YES];
    return [self.configurableOptions sortedArrayUsingDescriptors:@[sdSequence]];
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

// TODO: use this
//- (BOOL)isEqual:(id)object {
//    if ([object isKindOfClass:self.class]) {
//        MProductInfo *anotherProduct = (MProductInfo *)object;
//        if ([self.id isEqual:anotherProduct.id]) {
//            return YES;
//        }
//    }
//    return NO;
//}

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
