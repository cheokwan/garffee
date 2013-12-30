//
//  MOrderInfo.m
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MOrderInfo.h"
#import "MItemInfo.h"
#import "RestManager.h"


@implementation MOrderInfo

@dynamic id;
@dynamic userID;
@dynamic price;
@dynamic orderedDate;
@dynamic status;
@dynamic pickupTime;
@dynamic priority;
@dynamic expectedArrivalTime;
@dynamic referenceNumber;
@dynamic storeBranchID;
@dynamic items;

+ (MOrderInfo *)newOrderInfoInContext:(NSManagedObjectContext *)context {
    MOrderInfo *order = [MOrderInfo newObjectInContext:context];
    order.status = MOrderInfoStatusInCart;
    [order updatePrice];
    return order;
}

- (void)updatePrice {
    double total = 0.0;
    for (MItemInfo *item in self.items) {
        [item updatePrice];
        total += [item.price doubleValue];
    }
    self.price = @(total);
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                    @"id",
                                                  @"UserId":                @"userID",
                                                  @"Price":                 @"price",
                                                  @"OrderedDateTime":       @"orderedDate",
                                                  @"Status":                @"status",
                                                  @"PickupDateTime":        @"pickupTime",
                                                  @"Priority":              @"priority",
                                                  @"ExpectedArrivalDateTime": @"expectedArrivalTime",
                                                  @"ReferenceNumber":       @"referenceNumber",
                                                  @"StoreBranchId":         @"storeBranchID",
                                                  }];
    mapping.identificationAttributes = @[@"id"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Items" toKeyPath:@"items" withMapping:[MItemInfo defaultEntityMapping]]];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

- (NSString *)description {
    return [NSString stringWithFormat:
            @"id:%@, "
            @"userID:%@, "
            @"price:%@, "
            @"orderedDate:%@, "
            @"status:%@, "
            @"pickupTime:%@, "
            @"priority:%@, "
            @"expectedArrivalTime:%@, "
            @"referenceNumber:%@, "
            @"storeBranchID:%@, ",
            self.id,
            self.userID,
            self.price,
            self.orderedDate,
            self.status,
            self.pickupTime,
            self.priority,
            self.expectedArrivalTime,
            self.referenceNumber,
            self.storeBranchID
            ];
}

@end
