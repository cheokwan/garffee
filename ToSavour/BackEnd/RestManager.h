//
//  RestManager.h
//  ToSavour
//
//  Created by Jason Wan on 19/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol RestManagerResponseHandler <NSObject>
- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo;
- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo;
@end


@interface RestManager : NSObject

@property (nonatomic, readonly) NSString *facebookToken;
@property (nonatomic, strong, readonly) NSString *appToken;
@property (nonatomic, strong, readonly) RKCompoundValueTransformer *defaultDotNetValueTransformer;
@property (nonatomic, strong, readonly) RKDotNetDateFormatter *defaultDotNetDateFormatter;

+ (RestManager *)sharedInstance;
- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppProductInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchAppConfigurations:(__weak id<RestManagerResponseHandler>)handler;

@end
