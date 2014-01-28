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

@dynamic expectedArrivalTime;
@dynamic id;
@dynamic orderedDate;
@dynamic pickupTime;
@dynamic price;
@dynamic priority;
@dynamic referenceNumber;
@dynamic status;
@dynamic storeBranchID;
@dynamic userID;
@dynamic items;
@dynamic storeBranch;
@dynamic recipient;

+ (MOrderInfo *)newOrderInfoInContext:(NSManagedObjectContext *)context {
    MOrderInfo *order = [MOrderInfo newObjectInContext:context];
    order.status = MOrderInfoStatusInCart;
    [order updatePrice];
    return order;
}

+ (MOrderInfo *)existingOrNewOrderInfoInContext:(NSManagedObjectContext *)context {
    MOrderInfo *order = (MOrderInfo *)[MOrderInfo existingOrNewObjectInContext:context withPredicate:[NSPredicate predicateWithFormat:@"status =[c] %@", MOrderInfoStatusInCart]];  // XXX-TEST
    order.status = MOrderInfoStatusInCart;
    [order updatePrice];
    return order;
}

- (void)deleteInContext:(NSManagedObjectContext *)context {
    [super deleteInContext:context];
    // assert object has been deleted  XXX-TEST
    NSFetchRequest *fetchRequest;
    NSArray *fetchResults;
    fetchRequest = [MOrderInfo fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MOrderInfo found: %@", fetchResults);
    fetchRequest = [MItemInfo fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MItemInfo found: %@", fetchResults);
    fetchRequest = [MItemSelectedOption fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %@", @0];
    fetchResults = [context executeFetchRequest:fetchRequest error:nil];
    NSAssert(fetchResults.count == 0, @"zombie MItemSelectedOption found: %@", fetchResults);
}

- (NSURL *)URLForImageRepresentation {
    if (self.items.count > 0) {
        MItemInfo *item = [self.items allObjects][0];
        return item.product.URLForImageRepresentation;
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

- (void)updateRecipient:(MUserInfo *)recipient {
    if (recipient.appID.length > 0) {
        self.recipient = recipient;
        self.userID = recipient.appID;
    } else {
        self.recipient = nil;
        //self.userID = nil;  // triggered automatically
    }
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self changePrimitiveValue:value forKey:key];
    if ([key isEqualToString:@"storeBranchID"]) {
        NSFetchRequest *fetchRequest = [MBranch fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"branchId = %@", self.storeBranchID];
        NSManagedObject *branchObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.storeBranch && branchObject && [branchObject isKindOfClass:MBranch.class]) {
            [self changePrimitiveValue:branchObject forKey:@"storeBranch"];
        }
    } else if ([key isEqualToString:@"userID"]) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appID = %@", self.userID];
        NSManagedObject *userObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.recipient && userObject && [userObject isKindOfClass:MUserInfo.class]) {
            [self changePrimitiveValue:userObject forKey:@"recipient"];
        }
    } else if ([key isEqualToString:@"storeBranch"]) {
        [self changePrimitiveValue:self.storeBranch.branchId forKey:@"storeBranchID"];
    } else if ([key isEqualToString:@"recipient"]) {
        [self changePrimitiveValue:self.recipient.appID forKey:@"userID"];
    }
}

- (void)setStoreBranchID:(NSNumber *)storeBranchID {
    [self changeValue:storeBranchID forKey:@"storeBranchID"];
}

- (void)setUserID:(NSString *)userID {
    [self changeValue:userID forKey:@"userID"];
}

- (void)setStoreBranch:(MBranch *)storeBranch {
    [self changeValue:storeBranch forKey:@"storeBranch"];
}

- (void)setRecipient:(MUserInfo *)recipient {
    [self changeValue:recipient forKey:@"recipient"];
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

+ (RKEntityMapping *)giftCouponCreationEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{//@"Id": @"",
                                                  //@"ReferenceCode": @"",
                                                  //@"SponsorName": @"",
                                                  //@"SenderUserId": @"",
                                                  @"ReceiverUserId": @"userID",
                                                  @"CreatedDateTime": @"orderedDate",
                                                  //@"RedeemedDateTime": @"",
                                                  @"Price": @"price",
                                                  }];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Items" toKeyPath:@"items" withMapping:[MItemInfo defaultEntityMapping]]];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return [mapping inverseMapping];
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
