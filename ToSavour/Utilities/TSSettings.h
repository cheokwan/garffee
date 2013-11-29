//
//  TSSettings.h
//  ToSavour
//
//  Created by Jason Wan on 29/11/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSettings : NSObject

@property (nonatomic, strong)   NSData *apnsToken;


+ (TSSettings *)sharedInstance;
- (BOOL)isLocationServiceRestricted;
- (BOOL)isLocationServiceDenied;
- (BOOL)isLocationServiceAvailable;
- (BOOL)isAPNSDenied;
- (BOOL)isAPNSAvailable;
- (BOOL)isBackgroundRefreshRestricted;
- (BOOL)isBackgroundRefreshDenied;
- (BOOL)isBackgroundRefreshAvailable;

@end
