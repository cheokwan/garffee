//
//  TSSettings.m
//  ToSavour
//
//  Created by Jason Wan on 29/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSSettings.h"
#import <CoreLocation/CoreLocation.h>

@implementation TSSettings

+ (TSSettings *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static TSSettings *instance = nil;  // __strong is default already
    dispatch_once(&token, ^{
        instance = [[TSSettings alloc] init];
    });
    return instance;
}

- (void)initialize {
    self.apnsToken = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (BOOL)isLocationServiceRestricted {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted;
}

- (BOOL)isLocationServiceDenied {
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied;
}

- (BOOL)isLocationServiceAvailable {
    return [CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized;
}

- (BOOL)isAPNSDenied {  // TODO: should not be called before APNS token is requested
    // for now, treat !available as denied
    return ![self isAPNSAvailable];
}

- (BOOL)isAPNSAvailable {
    return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone && _apnsToken != nil;
}

// background refresh affects both pure background fetch and background location update AFAIK
// APNS doesn't seem to be affected
- (BOOL)isBackgroundRefreshRestricted {
    return [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted;
}

- (BOOL)isBackgroundRefreshDenied {
    return [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied;
}

- (BOOL)isBackgroundRefreshAvailable {
    return [[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusAvailable;
}

@end
