//
//  DataFetchManager.h
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestManager.h"

/**
 *  DataFetchManagerHandler
 *
 *  - Protocol for the DataFetchManager response callback handler
 */
@protocol DataFetchManagerHandler <NSObject>

/**
 *  Callback when the DataFetchManager service call succeeded
 *
 *  @param selector - the selector of the service call that succeeded
 *  @param userInfo - any other custom return values overflow to this dictionary
 */
- (void)dataFetchManagerService:(SEL)selector succeededWithUserInfo:(NSDictionary *)userInfo;

/**
 *  Callback when the DataFetchManager service call failed
 *
 *  @param selector - the selector of the service call that failed
 *  @param error - the associated error object
 *  @param userInfo - any other custom return values overflow to this dictionary
 */
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

/**
 *  The singleton shared instance of DataFetchManager
 *
 *  @return the singleton instance
 */
+ (instancetype)sharedInstance;

/**
 *  Fetches local address book contacts
 *
 *  @param context - the context for creating and saving the contacts objects
 *  @param handler - the callback handler
 */
- (void)fetchAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;

/**
 *  Wrapper around RestManager queryFacebookContacts
 *
 *  @param context - the context to fetch the Facebook contacts from
 *  @param handler - the callback handler
 */
- (void)discoverFacebookAppUsersInContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;

/**
 *  Wrapper around RestManager queryAddressBookContactsInContext
 *
 *  @param context - the context to fetch the address book contacts from
 *  @param handler - the callback handler
 */
- (void)discoverAddressBookAppUsersContext:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;

/**
 *  Caches the product images locally
 *
 *  @param context - the context to fetch the product objects from
 *  @param handler - the callback handler
 */
- (void)cacheLocalProductImages:(NSManagedObjectContext *)context handler:(id<DataFetchManagerHandler>)handler;

/**
 *  Generic wrapper around RestManager operations that handle a number of retries
 *
 *  @param fetchSelector - the RestManager selector to perform
 *  @param retries - the number of retries to perform in case the fetch failed
 */
- (void)performRestManagerFetch:(SEL)fetchSelector retries:(NSInteger)retries;

@end
