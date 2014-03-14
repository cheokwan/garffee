//
//  SessionManager.m
//  ToSavour
//
//  Created by Jason Wan on 13/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SessionManager.h"
#import "TSModelIncludes.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation SessionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static id instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)loginWithFacebookCredentials {
    [[RestManager sharedInstance] fetchFacebookAppUserInfo:self];  // bootstrap with fetching facebook app user info
}

- (void)logoutAndClearDatabase {
    // nuke the database
    NSManagedObjectContext *context = [AppDelegate sharedAppDelegate].managedObjectContext;
    [MUserInfo removeAllObjectsInContext:context];
    [MProductInfo removeAllObjectsInContext:context];
    [MProductConfigurableOption removeAllObjectsInContext:context];
    [MProductOptionChoice removeAllObjectsInContext:context];
    [MOrderInfo removeAllObjectsInContext:context];
    [MItemInfo removeAllObjectsInContext:context];
    [MItemSelectedOption removeAllObjectsInContext:context];
    [MCouponInfo removeAllObjectsInContext:context];
    [MGlobalConfiguration removeAllObjectsInContext:context];
    [MBranch removeAllObjectsInContext:context];
    [context saveToPersistentStore];
    
    // clear facebook session
    [[FBSession activeSession] closeAndClearTokenInformation];
    
    if ([_delegate respondsToSelector:@selector(sessionManagerDidLogout)]) {
        [_delegate sessionManagerDidLogout];
    }
}

#pragma mark - RestManagerResponseHandler

- (void)restManagerService:(SEL)selector succeededWithOperation:(NSOperation *)operation userInfo:(NSDictionary *)userInfo {
    DDLogInfo(@"registration REST operation succeeded: %@ - %@", NSStringFromSelector(selector), userInfo);
    
    if (selector == @selector(fetchFacebookAppUserInfo:)) {
        // fetched facebook info, now move onto fetching app user info with
        // facebook credentials
        MUserFacebookInfo *facebookAppUser = [[userInfo objectForKey:@"mappingResult"] firstObject];
        if (facebookAppUser) {
            facebookAppUser.isAppUser = @YES;
            [[AppDelegate sharedAppDelegate].managedObjectContext save];
            [[RestManager sharedInstance] fetchAppUserInfo:self];
            [[DataFetchManager sharedInstance] fetchAddressBookContactsInContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
            if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
                CGFloat progress = (CGFloat)SessionManagerLoginStageAppUser / SessionManagerLoginStageTotal;
                [_delegate sessionManagerDidUpdateLoginProgress:progress];
            }
        } else {
            DDLogError(@"unable to retrieve the mapped facebook user info");
            if ([_delegate respondsToSelector:@selector(sessionManagerDidFailToLoginWithError:)]) {
                NSError *error = [NSError errorWithDomain:@"login" code:666 userInfo:@{NSLocalizedDescriptionKey: @"unable to retrieve the mapped facebook user info"}];
                [_delegate sessionManagerDidFailToLoginWithError:error];
            }
        }
    }
    if (selector == @selector(fetchAppUserInfo:)) {
        [[RestManager sharedInstance] fetchFacebookFriendsInfo:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageFacebookFriends / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    if (selector == @selector(fetchFacebookFriendsInfo:)) {
        // successfully logged in and registered user info, now fetch app configs
        [[RestManager sharedInstance] fetchAppConfigurations:self];
        [[DataFetchManager sharedInstance] discoverFacebookAppUsersInContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
        [[DataFetchManager sharedInstance] discoverAddressBookAppUsersContext:[AppDelegate sharedAppDelegate].managedObjectContext handler:nil];
        
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppConfigurations / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    // TODO: make following calls parallel
    if (selector == @selector(fetchAppConfigurations:)) {
        // successfully fetched app configs, now fetch products info
        [[RestManager sharedInstance] fetchAppProductInfo:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppProducts / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    if (selector == @selector(fetchAppProductInfo:)) {
        [[RestManager sharedInstance] fetchBranches:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppStoreBranches / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    if (selector == @selector(fetchBranches:)) {
        [[RestManager sharedInstance] fetchAppOrderHistories:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppOrderHistories / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    if (selector == @selector(fetchAppOrderHistories:)) {
        [[RestManager sharedInstance] fetchAppCouponInfo:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppGiftCoupons / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
    if (selector == @selector(fetchAppCouponInfo:)) {
        [[DataFetchManager sharedInstance] cacheLocalProductImages:[AppDelegate sharedAppDelegate].managedObjectContext handler:self];
        if ([_delegate respondsToSelector:@selector(sessionManagerDidUpdateLoginProgress:)]) {
            CGFloat progress = (CGFloat)SessionManagerLoginStageAppProductImages / SessionManagerLoginStageTotal;
            [_delegate sessionManagerDidUpdateLoginProgress:progress];
        }
    }
}

- (void)restManagerService:(SEL)selector failedWithOperation:(NSOperation *)operation error:(NSError *)error userInfo:(NSDictionary *)userInfo {
    DDLogError(@"error in registration REST operation: %@, %@ - %@", NSStringFromSelector(selector), error, userInfo);
    if ([_delegate respondsToSelector:@selector(sessionManagerDidFailToLoginWithError:)]) {
        [_delegate sessionManagerDidFailToLoginWithError:error];
    }
}

#pragma mark - DataFetchManagerHandler

- (void)dataFetchManagerService:(SEL)selector succeededWithUserInfo:(NSDictionary *)userInfo {
    DDLogInfo(@"registration data fetch operation succeeded: %@ - %@", NSStringFromSelector(selector), userInfo);
    // successfully fetched everything, now dismiss the login view
    if ([_delegate respondsToSelector:@selector(sessionManagerDidLoginSuccessfully)]) {
        [_delegate sessionManagerDidLoginSuccessfully];
    }
}

- (void)dataFetchManagerService:(SEL)selector failedWithError:(NSError *)error userInfo:(NSDictionary *)userInfo {
    DDLogError(@"error in registration data fetch operation: %@, %@ - %@", NSStringFromSelector(selector), error, userInfo);
    // still dismiss for now although there were errors fetching one or more images
    if ([_delegate respondsToSelector:@selector(sessionManagerDidLoginSuccessfully)]) {
        [_delegate sessionManagerDidLoginSuccessfully];
    }
}

@end
