//
//  DataFetchManager.h
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestManager.h"

@protocol DataFetchManagerHandler <NSObject>
- (void)dataFetchManagerService:(SEL)selector succeededWithUserInfo:(NSDictionary *)userInfo;
- (void)dataFetchManagerService:(SEL)selector failedWithError:(NSError *)error userInfo:(NSDictionary *)userInfo;
@end


/**
 *  DataFetchManager
 *
 *  - Performs local but potentially time-consuming data fetch/store operations
 *  - Wrapper against RestManager provided REST operations to include retries capability
 *  - On success, the callback handler method dataFetchManagerService:succeededWithUserInfo: will be called
 *  - On failure, the callback handler method dataFetchManagerService:failedWithError:userInfo: will be called
 */
@interface DataFetchManager : NSObject<RestManagerResponseHandler>

+ (instancetype)sharedInstance;
- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;
- (void)discoverFacebookAppUsersInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;
- (void)discoverAddressBookAppUsersContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;
- (void)cacheLocalProductImages:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;

- (void)performRestManagerFetch:(SEL)fetchSelector retries:(NSInteger)retries;

@end
