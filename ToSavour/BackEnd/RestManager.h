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
@property (nonatomic, readonly) NSString *appToken;

+ (RestManager *)sharedInstance;
- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler;

@end
