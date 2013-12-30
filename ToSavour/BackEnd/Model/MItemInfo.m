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
#import "RestManager.h"


@implementation MItemInfo

@dynamic creationDate;
@dynamic id;
@dynamic price;
@dynamic status;
@dynamic productID;
@dynamic couponID;
@dynamic orderID;
@dynamic itemSelectedOptions;
@dynamic product;
@dynamic order;

+ (id)newItemInfoWithProduct:(MProductInfo *)product optionChoices:(NSArray *)choices inContext:(NSManagedObjectContext *)context {
    MItemInfo *item = [MItemInfo newObjectInContext:context];
    item.product = product;
    for (MProductOptionChoice *choice in choices) {
        MItemSelectedOption *selectedOption = [MItemSelectedOption newItemSelectedOptionWithOptionChoice:choice inContext:context];
        [item addItemSelectedOptionsObject:selectedOption];
    }
    
    item.creationDate = [NSDate date];
    item.status = MOrderInfoStatusInCart;
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
