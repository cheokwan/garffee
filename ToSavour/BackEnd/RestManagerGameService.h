//
//  RestManagerGameService.h
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RestManager.h"
#import "TSGame.h"
#import "TSGamePlayHistory.h"

@interface RestManagerGameService : RestManager

+ (RestManagerGameService *)sharedInstance;

- (void)fetchConfiguration:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchGameList:(__weak id<RestManagerResponseHandler>)handler;
- (void)fetchGameHistories:(__weak id<RestManagerResponseHandler>)handler;
- (void)postGameStart:(__weak id<RestManagerResponseHandler>)handler game:(TSGame *)game;
- (void)updateGameResult:(__weak id<RestManagerResponseHandler>)handler gameHistory:(TSGamePlayHistory *)gameHistory;

- (void)removeAllGameHistories;  // XXX-DEBUG: for debug purpose

@end
