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

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self changePrimitiveValue:value forKey:key];
    if ([key isEqualToString:@"itemID"]) {
        NSFetchRequest *fetchRequest = [MItemInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.itemID];
        NSManagedObject *itemObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.item && itemObject && [itemObject isKindOfClass:MItemInfo.class]) {
            [self changePrimitiveValue:itemObject forKey:@"item"];
        }
    } else if ([key isEqualToString:@"optionChoiceID"]) {
        NSFetchRequest *fetchRequest = [MProductOptionChoice fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.optionChoiceID];
        NSManagedObject *choiceObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.productOptionChoice && choiceObject && [choiceObject isKindOfClass:MProductOptionChoice.class]) {
            [self changePrimitiveValue:choiceObject forKey:@"productOptionChoice"];
        }
    } else if ([key isEqualToString:@"item"]) {
        [self changePrimitiveValue:self.item.id forKey:@"itemID"];
    } else if ([key isEqualToString:@"productOptionChoice"]) {
        [self changePrimitiveValue:self.productOptionChoice.id forKey:@"optionChoiceID"];
    }
}

- (void)setItemID:(NSNumber *)itemID {
    [self changeValue:itemID forKey:@"itemID"];
}

- (void)setOptionChoiceID:(NSNumber *)optionChoiceID {
    [self changeValue:optionChoiceID forKey:@"optionChoiceID"];
}

- (void)setProductOptionChoice:(MProductOptionChoice *)productOptionChoice {
    [self changeValue:productOptionChoice forKey:@"productOptionChoice"];
}

- (void)setItem:(MItemInfo *)item {
    [self changeValue:item forKey:@"item"];
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
