//
//  MFriendInfo.m
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "MFriendInfo.h"
#import "NSManagedObject+Helper.h"


@implementation MFriendInfo

@dynamic canSendGift;

+ (id)newFriendInfoInContext:(NSManagedObjectContext *)context {
    return (MFriendInfo *)[self.class newObjectInContext:context];
}

+ (RKResponseDescriptor *)defaultResponseDescriptor {
    return [RKResponseDescriptor responseDescriptorWithMapping:[self.class defaultEntityMapping] method:RKRequestMethodAny pathPattern:nil keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

@end
