//
//  MOrderInfo.m
//  ToSavour
//
//  Created by Jason Wan on 24/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MOrderInfo.h"
#import "MItemInfo.h"
#import "MItemSelectedOption.h"
#import "MProductInfo.h"
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
    order.status = MOrderInfoStatusPending;
    [order updatePrice];
    return order;
}

+ (MOrderInfo *)existingOrNewOrderInfoInContext:(NSManagedObjectContext *)context {
    MOrderInfo *order = (MOrderInfo *)[MOrderInfo existingOrNewObjectInContext:context withPredicate:[NSPredicate predicateWithFormat:@"status = %@", MOrderInfoStatusPending]];  // XXX-TEST
    order.status = MOrderInfoStatusPending;
    [order updatePrice];
    return order;
}

- (void)deleteInContext:(NSManagedObjectContext *)context {
    [super deleteInContext:context];
    // assert object has been deleted  XXX-TEST
    NSFetchRequest *fetchRequest;
    NSArray *fetchResults;
    fetchRequest = [MOrderInfo fetchRequestInContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MOrderInfo found: %@", fetchResults);
    fetchRequest = [MItemInfo fetchRequestInContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MItemInfo found: %@", fetchResults);
    fetchRequest = [MItemSelectedOption fetchRequestInContext:context];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MItemSelectedOption found: %@", fetchResults);
}

- (NSString *)storeBranchName {
    // TODO: fetch branch name
    return @"Causeway Bay";
}

- (NSURL *)URLForImageRepresentation {
    if (self.items.count > 0) {
        MItemInfo *item = [self.items allObjects][0];
        NSString *urlString = [item.product resolvedImageURL];
        if (urlString.length > 0) {
            return [NSURL URLWithString:urlString];
        }
    }
    return nil;
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
