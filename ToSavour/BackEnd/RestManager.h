//
//  RestManager.h
//  ToSavour
//
//  Created by Jason Wan on 19/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOrderInfo.h"
#import "TSGame.h"
#import "TSGamePlayHistory.h"

/**
 *  RestManagerResponseHandler
 *
 *  - Protocol for the RestManager response callback handler
 */
@protocol RestManagerResponseHandler <NSObject>

/**
 *  Callback when the RestManager service call succeeded
 *
 *  @param selector - the selector of the service call that succeeded
 *  @param operation - the associated request operation
 *  @param userInfo - any other custom return values overflow to this dictionary
 */
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo;

/**
 *  Callback when the RestManager service call failed
 *
 *  @param selector - the selector of the service call that failed
 *  @param operation - the associated request operation
 *  @param error - the associated error object
 *  @param userInfo - any other custom return values overflow to this dictionary
 */
- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo;
@end


typedef enum {
    RestManagerServiceHostApp = 0,
    RestManagerServiceHostFacebook,
} RestManagerServiceHostType;

static const NSString *facebookAPIBaseURLString = @"https://graph.facebook.com";
static const NSString *appAPIBaseURLString = @"http://f34e2b0b303842659d3e58ed6dc844a5.cloudapp.net:8080/RESTfulWCFUsersServiceEndPoint.svc";
//static const NSString *appAPIBaseURLString = @"http://10.0.1.13:8081/RESTfulWCFUsersServiceEndPoint.svc";  // XXX-TEST


/**
 *  RestManager
 *
 *  - Performs all REST related network calls against Facebook or App API.
 *  - All data will be fetched and serialized automatically to respective CoreData models.
 *  - On success, the callback handler method restManagerService:succeededWithOperation:userInfo: will be called
 *  - On failure, the callback handler method restManagerService:failedWithOperation:error:userInfo: will be called
 */
@interface RestManager : NSObject

@property (nonatomic, readonly)         NSString *facebookToken;
@property (nonatomic, strong, readonly) NSString *appToken;
@property (nonatomic, strong, readonly) RKCompoundValueTransformer *defaultDotNetValueTransformer;
@property (nonatomic, strong, readonly) RKDotNetDateFormatter *defaultDotNetDateFormatter;
@property (nonatomic, strong)           NSOperationQueue *operationQueue;


/**
 *  The singleton shared instance of RestManager
 *
 *  @return the singleton instance
 */
+ (instancetype)sharedInstance;


/**
 *  Fetches user info with Facebook credentials against Facebook API
 *
 *  @prarm handler - the callback handler
 */
- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches user Facebook friends info against Facebook API
 *
 *  @prarm handler - the callback handler
 */
- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app user info with user's Facebook credentials
 *
 *  @prarm handler - the callback handler
 */
- (void)fetchAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app product info, available products, options etc
 *
 *  @prarm handler - the callback handler
 */
- (void)fetchAppProductInfo:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app global configurations
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppConfigurations:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app store branch info
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppBranches:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app user's coupons
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppCouponInfo:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches app user's order history
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppOrderHistories:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches ongoing pending orders for app user
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppPendingOrderStatus:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches list of games
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppGameList:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Fetches game histories
 *
 *  @param handler - the callback handler
 */
- (void)fetchAppGameHistories:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Updates app user info against server
 *
 *  @param userInfo - the app user info object to udpate
 *  @param handler - the callback handler
 */
- (void)putUserInfo:(MUserInfo *)userInfo handler:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Posts user's new order to server
 *
 *  @param order - the order object to post
 *  @param handler - the callback handler
 */
- (void)postOrder:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Posts user's new gift coupon to server
 *
 *  @param order - the order info object to post as a gift coupon
 *  @param handler - the callback handler
 */
- (void)postGiftCoupon:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Posts game start to server
 *
 *  @param handler - the callback handler
 *  @param game - the game object to start
 */
- (void)postGameStart:(__weak id<RestManagerResponseHandler>)handler game:(TSGame *)game;


/**
 *  Update game result
 *
 *  @param handler - the callback handler
 *  @param gameHistory - the game history to update
 */
- (void)updateGameResult:(__weak id<RestManagerResponseHandler>)handler gameHistory:(TSGamePlayHistory *)gameHistory;


/**
 *  Remove all game history, for debug purpose
 */
- (void)removeAllGameHistories;


/**
 *  Query user's Facebook contacts against server to find app-using friends
 *
 *  @param context - the context to fetch the Facebook contacts from
 *  @param handler - the callback handler
 */
- (void)queryFacebookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Query user's address book contacts against server to find app-using friends
 *
 *  @param context - the context to fetch the address book contacts from
 *  @param handler - the callback handler
 */
- (void)queryAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler;


/**
 *  Query the user's estimated arrival time for a store branch
 *
 *  @param branch - the branch object which ETA is to be queried
 *  @param handler - the callback handler
 */
- (void)queryEstimatedTimeForBranch:(MBranch *)branch handler:(__weak id<RestManagerResponseHandler>)handler;

@end


/**
 *  KVPair
 *
 *  - Utility class for abstracting a key-value pair
 */
@interface KVPair : NSObject<RKMappableObject>
@property (nonatomic, strong)   NSString *key;
@property (nonatomic, strong)   id value;
@end