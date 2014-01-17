//
//  DataFetchManager.h
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestManager.h"

@interface DataFetchManager : NSObject<RestManagerResponseHandler>

+ (instancetype)sharedInstance;
- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context;
- (void)discoverFacebookAppUsersInContext:(NSManagedObjectContext *)context;
- (void)discoverAddressBookAppUsersContext:(NSManagedObjectContext *)context;

@end
