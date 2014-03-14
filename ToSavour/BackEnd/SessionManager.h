//
//  SessionManager.h
//  ToSavour
//
//  Created by Jason Wan on 13/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestManager.h"
#import "DataFetchManager.h"

typedef enum {
    SessionManagerLoginStageFacebookAppUser = 1,
    SessionManagerLoginStageAppUser = 2,
    SessionManagerLoginStageFacebookFriends = 3,
    SessionManagerLoginStageAppConfigurations = 4,
    SessionManagerLoginStageAppProducts = 5,
    SessionManagerLoginStageAppStoreBranches = 6,
    SessionManagerLoginStageAppOrderHistories = 7,
    SessionManagerLoginStageAppGiftCoupons = 8,
    SessionManagerLoginStageAppProductImages = 9,  // give more weight
    SessionManagerLoginStageTotal = 12
} SessionManagerLoginStage;


@protocol SessionManagerDelegate <NSObject>
- (void)sessionManagerDidUpdateLoginProgress:(CGFloat)progress;
- (void)sessionManagerDidLoginSuccessfully;
- (void)sessionManagerDidFailToLoginWithError:(NSError *)error;
@optional
- (void)sessionManagerDidLogout;
@end


@interface SessionManager : NSObject<RestManagerResponseHandler, DataFetchManagerHandler>
@property (nonatomic, weak) id<SessionManagerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void)loginWithFacebookCredentials;
- (void)logoutAndClearDatabase;

@end
