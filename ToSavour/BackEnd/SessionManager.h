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
    SessionManagerLoginStageAppProductImages = 9,  // give more weight to the product image fetching stage
    SessionManagerLoginStageTotal = 12
} SessionManagerLoginStage;


/**
 *  SessionManagerDelegate
 *
 *  - Delegate protocol for SessionManager's callbacks
 */
@protocol SessionManagerDelegate <NSObject>

/**
 *  Callback after SessionManager updated login progress
 *
 *  @param progress - normalized progress in float between 0.0 to 1.0,
 *                    derived from SessionManagerLoginStage
 */
- (void)sessionManagerDidUpdateLoginProgress:(CGFloat)progress;

/**
 *  Callback after user is logged in successfully
 */
- (void)sessionManagerDidLoginSuccessfully;

/**
 *  Callback after user failed to login
 *
 *  @param error - the error object associated with the failure
 */
- (void)sessionManagerDidFailToLoginWithError:(NSError *)error;

@optional
/**
 *  Callback after user logged out successfully
 */
- (void)sessionManagerDidLogout;
@end


/**
 *  SessionManager
 *
 *  - Responsible for the app login/logout and session for a user
 */
@interface SessionManager : NSObject<RestManagerResponseHandler, DataFetchManagerHandler>
@property (nonatomic, weak) id<SessionManagerDelegate> delegate;

/**
 *  The singleton shared instance of SessionManager
 *
 *  @return the singleton instance
 */
+ (instancetype)sharedInstance;

/**
 *  Login the user to app with existing user's Facebook credentials
 */
- (void)loginWithFacebookCredentials;

/**
 *  Logout the app user and clear everything in the database associated with the user
 */
- (void)logoutAndClearDatabase;

@end
