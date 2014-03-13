//
//  MItemInfo.m
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MItemInfo.h"
#import "MItemSelectedOption.h"
#import "MOrderInfo.h"
#import "MProductInfo.h"
#import "MProductOptionChoice.h"
#import "MCouponInfo.h"
#import "RestManager.h"


@implementation MItemInfo

@dynamic couponID;
@dynamic creationDate;
@dynamic id;
@dynamic orderID;
@dynamic price;
@dynamic productID;
@dynamic status;
@dynamic quantity;
@dynamic coupon;
@dynamic itemSelectedOptions;
@dynamic order;
@dynamic product;

+ (id)newItemInfoWithProduct:(MProductInfo *)product optionChoices:(NSArray *)choices inContext:(NSManagedObjectContext *)context {
    MItemInfo *item = [MItemInfo newObjectInContext:context];
    item.product = product;
    [item addOptionChoices:choices];
    
    item.creationDate = [NSDate date];
    item.status = MOrderInfoStatusPending;
    item.quantity = @1;  // TODO: handle quantity
    [item updatePrice];
    return item;
}

- (void)deleteAllSelectedOptions {
    NSArray *allSelectedOptions = [self.itemSelectedOptions allObjects];
    for (MItemSelectedOption *selectedOption in allSelectedOptions) {
        [self removeItemSelectedOptionsObject:selectedOption];
        [selectedOption deleteInContext:self.managedObjectContext];
    }
}

- (void)addOptionChoices:(NSArray *)choices {
    for (MProductOptionChoice *choice in choices) {
        MItemSelectedOption *selectedOption = [MItemSelectedOption newItemSelectedOptionWithOptionChoice:choice inContext:self.managedObjectContext];
        [self addItemSelectedOptionsObject:selectedOption];
    }
}

- (NSString *)detailString {
    NSMutableArray *optionNames = [NSMutableArray array];
    NSSortDescriptor *sdOptionChoiceID = [NSSortDescriptor sortDescriptorWithKey:@"optionChoiceID" ascending:YES];
    NSArray *options = [self.itemSelectedOptions sortedArrayUsingDescriptors:@[sdOptionChoiceID]];
    for (MItemSelectedOption *option in options) {
        [optionNames addObject:option.productOptionChoice.name];
    }
    // XXX-TEMP: default to showing 2 option names temporarily, pending product decision
    return [[optionNames objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(optionNames.count, 2))]] commaSeparatedString];
}

- (void)updatePrice {
    double total = 0.0;
    for (MItemSelectedOption *selectedOption in self.itemSelectedOptions) {
        total += [selectedOption.productOptionChoice.price doubleValue];
    }
    self.price = @(total * [self.quantity intValue]);
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self changePrimitiveValue:@1 forKey:@"quantity"];
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self changePrimitiveValue:value forKey:key];
    if ([key isEqualToString:@"productID"]) {
        NSFetchRequest *fetchRequest = [MProductInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.productID];
        NSManagedObject *productObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (productObject && [productObject isKindOfClass:MProductInfo.class]) {
            [self changePrimitiveValue:productObject forKey:@"product"];
        }
    } else if ([key isEqualToString:@"orderID"]) {
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.orderID];
        NSManagedObject *orderObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (orderObject && [orderObject isKindOfClass:MOrderInfo.class]) {
            [self changePrimitiveValue:orderObject forKey:@"order"];
        }
    } else if ([key isEqualToString:@"couponID"]) {
        NSFetchRequest *fetchRequest = [MCouponInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.couponID];
        NSManagedObject *couponObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (couponObject && [couponObject isKindOfClass:MCouponInfo.class]) {
            [self changePrimitiveValue:couponObject forKey:@"coupon"];
        }
    } else if ([key isEqualToString:@"product"]) {
        if (self.product.id) {
            [self changePrimitiveValue:self.product.id forKey:@"productID"];
        }
    } else if ([key isEqualToString:@"order"]) {
        if (self.order.id) {
            [self changePrimitiveValue:self.order.id forKey:@"orderID"];
        }
    } else if ([key isEqualToString:@"coupon"]) {
        if (self.coupon.id) {
            [self changePrimitiveValue:self.coupon.id forKey:@"couponID"];
        }
    } else if ([key isEqualToString:@"quantity"]) {
        if (self.itemSelectedOptions.count > 0) {
            // XXX-SERVER-BUG  update price when server returns no item selected options set it to 0
            [self updatePrice];
        }
    }
}

- (void)setProductID:(NSNumber *)productID {
    [self changeValue:productID forKey:@"productID"];
}

- (void)setOrderID:(NSNumber *)orderID {
    [self changeValue:orderID forKey:@"orderID"];
}

- (void)setCouponID:(NSNumber *)couponID {
    [self changeValue:couponID forKey:@"couponID"];
}

- (void)setProduct:(MProductInfo *)product {
    [self changeValue:product forKey:@"product"];
}

- (void)setOrder:(MOrderInfo *)order {
    [self changeValue:order forKey:@"order"];
}

- (void)setCoupon:(MCouponInfo *)coupon {
    [self changeValue:coupon forKey:@"coupon"];
}

- (void)setQuantity:(NSNumber *)quantity {
    [self changeValue:quantity forKey:@"quantity"];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"id",
                                                  @"Price":             @"price",
                                                  @"ProductId":         @"productID",
                                                  @"Status":            @"status",
                                                  @"CreatedDateTime":   @"creationDate",
                                                  @"CouponId":          @"couponID",
                                                  @"OrderId":           @"orderID"}];
    mapping.identificationAttributes = @[@"id"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ItemSelectedOption" toKeyPath:@"itemSelectedOptions" withMapping:[MItemSelectedOption defaultEntityMapping]]];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"id:%@, "
            @"price:%@, "
            @"productID:%@, "
            @"status:%@, "
            @"creationDate:%@, "
            @"couponID:%@, "
            @"orderID:%@, ",
            self.id,
            self.price,
            self.productID,
            self.status,
            self.creationDate,
            self.couponID,
            self.orderID
            ];
}

@end
