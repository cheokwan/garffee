//
//  MItemSelectedOption.m
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MItemSelectedOption.h"
#import "MItemInfo.h"
#import "MProductOptionChoice.h"
#import "RestManager.h"


@implementation MItemSelectedOption

@dynamic id;
@dynamic itemID;
@dynamic optionChoiceID;
@dynamic item;
@dynamic productOptionChoice;

+ (id)newItemSelectedOptionWithOptionChoice:(MProductOptionChoice *)choice inContext:(NSManagedObjectContext *)context {
    MItemSelectedOption *itemSelectedOption = [MItemSelectedOption newObjectInContext:context];
    itemSelectedOption.productOptionChoice = choice;
    return itemSelectedOption;
}

- (void)setProductOptionChoice:(MProductOptionChoice *)productOptionChoice {
    [self willChangeValueForKey:@"productOptionChoice"];
    [self setPrimitiveValue:productOptionChoice forKey:@"productOptionChoice"];
    [self didChangeValueForKey:@"productOptionChoice"];
    self.optionChoiceID = self.productOptionChoice.id;
}

- (void)setItem:(MItemInfo *)item {
    [self willChangeValueForKey:@"item"];
    [self setPrimitiveValue:item forKey:@"item"];
    [self didChangeValueForKey:@"item"];
    self.itemID = self.item.id;
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"id",
                                                  @"ItemId":            @"itemID",
                                                  @"OptionChoiceId":    @"optionChoiceID"}];
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
            @"itemID:%@, "
            @"optionChoiceID:%@, ",
            self.id,
            self.itemID,
            self.optionChoiceID
            ];
}

@end
