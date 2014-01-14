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
@dynamic itemSelectedOptions;
@dynamic order;
@dynamic product;
@dynamic coupon;

+ (id)newItemInfoWithProduct:(MProductInfo *)product optionChoices:(NSArray *)choices inContext:(NSManagedObjectContext *)context {
    MItemInfo *item = [MItemInfo newObjectInContext:context];
    item.product = product;
    for (MProductOptionChoice *choice in choices) {
        MItemSelectedOption *selectedOption = [MItemSelectedOption newItemSelectedOptionWithOptionChoice:choice inContext:context];
        [item addItemSelectedOptionsObject:selectedOption];
    }
    
    item.creationDate = [NSDate date];
    item.status = MOrderInfoStatusPending;
    [item updatePrice];
    return item;
}

- (void)setProduct:(MProductInfo *)product {
    [self willChangeValueForKey:@"product"];
    [self setPrimitiveValue:product forKey:@"product"];
    [self didChangeValueForKey:@"product"];
    self.productID = self.product.id;
}

- (void)setOrder:(MOrderInfo *)order {
    [self willChangeValueForKey:@"order"];
    [self setPrimitiveValue:order forKey:@"order"];
    [self didChangeValueForKey:@"order"];
    self.orderID = self.order.id;
}

- (void)updatePrice {
    double total = 0.0;
    for (MItemSelectedOption *selectedOption in self.itemSelectedOptions) {
        total += [selectedOption.productOptionChoice.price doubleValue];
    }
    self.price = @(total);
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didChangeValueForKey:key];
    if ([key isEqualToString:@"productID"]) {
        NSFetchRequest *fetchRequest = [MProductInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.productID];
        NSManagedObject *productObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.product && productObject && [productObject isKindOfClass:MProductInfo.class]) {
            self.product = (MProductInfo *)productObject;
        }
    } else if ([key isEqualToString:@"orderID"]) {
        NSFetchRequest *fetchRequest = [MOrderInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.orderID];
        NSManagedObject *orderObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.order && orderObject && [orderObject isKindOfClass:MOrderInfo.class]) {
            self.order = (MOrderInfo *)orderObject;
        }
    } else if ([key isEqualToString:@"couponID"]) {
        NSFetchRequest *fetchRequest = [MCouponInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", self.couponID];
        NSManagedObject *couponObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.coupon && couponObject && [couponObject isKindOfClass:MCouponInfo.class]) {
            self.coupon = (MCouponInfo *)couponObject;
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
