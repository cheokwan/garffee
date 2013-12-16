//
//  MFriendInfo.h
//  ToSavour
//
//  Created by Jason Wan on 12/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MUserInfo.h"


@interface MFriendInfo : MUserInfo

@property (nonatomic) BOOL canSendGift;

+ (id)newFriendInfoInContext:(NSManagedObjectContext *)context;

@end
