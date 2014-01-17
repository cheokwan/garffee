//
//  MCouponInfo.m
//  ToSavour
//
//  Created by Jason Wan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "MCouponInfo.h"
#import "MItemInfo.h"
#import "MUserInfo.h"
#import "MProductInfo.h"
#import "RestManager.h"


@implementation MCouponInfo

@dynamic creationDate;
@dynamic id;
@dynamic price;
@dynamic receiverUserID;
@dynamic redeemedDate;
@dynamic referenceCode;
@dynamic senderUserID;
@dynamic sponsorName;
@dynamic items;
@dynamic receiver;
@dynamic sender;

- (NSString *)issuerName {
    NSString *name = @"";
    if (self.sender) {
        name = self.sender.name;  // TODO: do remote fetch if user does not exist locally
    } else if (self.sponsorName) {
        name = self.sponsorName;
    }
    return name;
}

- (NSURL *)URLForImageRepresentation {
    if (self.items.count > 0) {
        MItemInfo *item = [self.items allObjects][0];
        NSString *urlString = [item.product resolvedImageURL];
        if (urlString.length > 0) {
            return [NSURL URLWithString:urlString];
        }
    }
//    return nil;
    return [NSURL URLWithString:@"http://1.bp.blogspot.com/-4TqWQzfscLY/Up4veCapg1I/AAAAAAAAPT8/UBX9a5WlbiE/s1600/Red-Holiday-Gift.png"];  // XXXXXX
}

- (void)changeValue:(id)value forKey:(NSString *)key {
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didChangeValueForKey:key];
    if ([key isEqualToString:@"senderUserID"]) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appID = %@", self.senderUserID];
        NSManagedObject *senderObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.sender && senderObject && [senderObject isKindOfClass:MUserInfo.class]) {
            self.sender = (MUserInfo *)senderObject;
        }
    } else if ([key isEqualToString:@"receiverUserID"]) {
        NSFetchRequest *fetchRequest = [MUserInfo fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"appID = %@", self.receiverUserID];
        NSManagedObject *receiverObject = [self.managedObjectContext fetchUniqueObject:fetchRequest];
        if (!self.receiver && receiverObject && [receiverObject isKindOfClass:MUserInfo.class]) {
            self.receiver = (MUserInfo *)receiverObject;
        }
    }
}

- (void)setSenderUserID:(NSString *)senderUserID {
    [self changeValue:senderUserID forKey:@"senderUserID"];
}

- (void)setReceiverUserID:(NSString *)receiverUserID {
    [self changeValue:receiverUserID forKey:@"receiverUserID"];
}

#pragma mark - RKMappableEntity

+ (RKEntityMapping *)defaultEntityMapping {
    RKEntityMapping *mapping = [RKEntityMapping mappingForEntityForName:NSStringFromClass(self.class) inManagedObjectStore:[RKManagedObjectStore defaultStore]];
    [mapping addAttributeMappingsFromDictionary:@{@"Id":                @"id",
                                                  @"ReferenceCode":     @"referenceCode",
                                                  @"SponsorName":       @"sponsorName",
                                                  @"SenderUserId":      @"senderUserID",
                                                  @"ReceiverUserId":    @"receiverUserID",
                                                  @"CreatedDateTime":   @"creationDate",
                                                  @"RedeemedDateTime":  @"redeemedDate",
                                                  @"Price":             @"price",
                                                  }];
    mapping.identificationAttributes = @[@"id"];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Items" toKeyPath:@"items" withMapping:[MItemInfo defaultEntityMapping]]];
    mapping.valueTransformer = [[RestManager sharedInstance] defaultDotNetValueTransformer];
    return mapping;
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
