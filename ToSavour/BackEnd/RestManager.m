//
//  RestManager.m
//  ToSavour
//
//  Created by Jason Wan on 19/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "RestManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TSModelIncludes.h"

@interface RestManager()
@property (nonatomic, strong)   RKObjectManager *facebookObjectManager;
@property (nonatomic, strong)   RKObjectManager *appObjectManager;
@end

@implementation RestManager
static const NSString *facebookAPIBaseURLString = @"https://graph.facebook.com";
static const NSString *appAPIBaseURLString = @"http://f34e2b0b303842659d3e58ed6dc844a5.cloudapp.net:8080/RESTfulWCFUsersServiceEndPoint.svc";

#pragma mark - Internal

+ (RestManager *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static RestManager *instance = nil;
    dispatch_once(&token, ^{
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);  // XXX-TEST
        instance = [[RestManager alloc] init];
    });
    return instance;
}

- (RKObjectManager *)facebookObjectManager {
    if (!_facebookObjectManager) {
        self.facebookObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:(NSString *)facebookAPIBaseURLString]];
//        [_facebookObjectManager addResponseDescriptorsFromArray:@[[MUserInfo defaultResponseDescriptor], [MFriendInfo defaultResponseDescriptor]]];
//        _facebookObjectManager.operationQueue = [NSOperationQueue currentQueue];
    }
    return _facebookObjectManager;
}

- (RKObjectManager *)appObjectManager {
    if (!_appObjectManager) {
        self.appObjectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:(NSString *)appAPIBaseURLString]];
    }
    return _appObjectManager;
}

- (NSString *)facebookToken {
    return [[[FBSession activeSession] accessTokenData] accessToken];
}

- (NSString *)appToken {
    return nil;
}


#pragma mark - Services

- (void)fetchFacebookAppUserInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch user info
    NSString *servicePath = [NSString stringWithFormat:@"/me/?access_token=%@&fields=id,name,username,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(120),picture.height(120)", self.facebookToken];
    NSURL *serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[[MUserInfo defaultResponseDescriptor]]];
    
    operation.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"mappingResult": mappingResult}];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogWarn(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [self.facebookObjectManager enqueueObjectRequestOperation:operation];
}


- (void)fetchFacebookFriendsInfo:(__weak id<RestManagerResponseHandler>)handler {
    // fetch friends info
    NSString *servicePath = [NSString stringWithFormat:@"/me/friends?access_token=%@&fields=id,name,username,first_name,middle_name,last_name,gender,age_range,link,locale,birthday,picture.width(120),picture.height(120)", self.facebookToken];
    NSURL *serviceURL = [NSURL URLWithString:[facebookAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    RKManagedObjectRequestOperation *operation = [[RKManagedObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[[MFriendInfo defaultResponseDescriptor]]];
    
    operation.managedObjectContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    operation.managedObjectCache = [RKManagedObjectStore defaultStore].managedObjectCache;
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"mappingResult": mappingResult}];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DDLogWarn(@"REST operation failed: %@", error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    [self.facebookObjectManager enqueueObjectRequestOperation:operation];
}

@end
