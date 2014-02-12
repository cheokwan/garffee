//
//  RestManager.h
//  ToSavour
//
//  Created by Jason Wan on 19/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOrderInfo.h"

@protocol RestManagerResponseHandler <NSObject>
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo;
- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo;
@end


typedef enum {
    RestManagerServiceHostApp = 0,
    RestManagerServiceHostFacebook,
} RestManagerServiceHostType;

static const NSString *facebookAPIBaseURLString = @"https://graph.facebook.com";
static const NSString *appAPIBaseURLString = @"http://f34e2b0b303842659d3e58ed6dc844a5.cloudapp.net:8080/RESTfulWCFUsersServiceEndPoint.svc";
//static const NSString *appAPIBaseURLString = @"http://10.0.1.13:8081/RESTfulWCFUsersServiceEndPoint.svc";  // XXX-TEST

@interface RestManager : NSObject

@property (nonatomic, readonly) NSString *facebookToken;
@property (nonatomic, strong, readonly) NSString *appToken;
@property (nonatomic, strong, readonly) RKCompoundValueTransformer *defaultDotNetValueTransformer;
@property (nonatomic, strong, readonly) RKDotNetDateFormatter *defaultDotNetDateFormatter;
@property (nonatomic, strong)   NSOperationQueue *operationQueue;

+ (instancetype)sharedInstance;
- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppProductInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppConfigurations:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchBranches:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppCouponInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppOrderHistories:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppPendingOrderStatus:(__weak id<RestManagerResponseHandler>)handler;

- (void)putUserInfo:(MUserInfo *)userInfo handler:(__weak id<RestManagerResponseHandler>)handler;
- (void)postOrder:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler;
- (void)postGiftCoupon:(MOrderInfo *)order handler:(__weak id<RestManagerResponseHandler>)handler;

- (void)queryFacebookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler;
- (void)queryAddressBookContactsInContext:(NSManagedObjectContext *)context handler:(__weak id<RestManagerResponseHandler>)handler;

@end



@interface KVPair : NSObject<RKMappableObject>
@property (nonatomic, strong)   NSString *key;
@property (nonatomic, strong)   id value;
@end