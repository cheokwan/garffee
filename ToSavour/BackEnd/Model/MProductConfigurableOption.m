//
//  MProductConfigurableOption.m
//  ToSavour
//
//  Created by Jason Wan on 23/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MProductConfigurableOption.h"
#import "MProductInfo.h"
#import "MProductOptionChoice.h"
#import "RestManager.h"


@implementation MProductConfigurableOption

@dynamic id;
@dynamic name;
@dynamic sequence;
@dynamic defaultChoice;
@dynamic choices;
@dynamic product;

- (NSArray *)sortedOptionChoices {
    NSSortDescriptor *sdId = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
    return [self.choices sortedArrayUsingDescriptors:@[sdId]];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":            @"id",
                                                  @"Name":          @"name",
                                                  @"Sequence":      @"sequence",
                                                  @"DefaultChoice": @"defaultChoice"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"OptionChoices" toKeyPath:@"choices" withMapping:[MProductOptionChoice defaultEntityMapping]]];
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
            @"sequence:%@ "
            @"defaultChoice:%@ ",
            self.id,
            self.name,
            self.sequence,
            self.defaultChoice];
}

@end
