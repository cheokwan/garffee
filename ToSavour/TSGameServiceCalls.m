//
//  TSGameServiceCalls.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "TSGameServiceCalls.h"

#import <AFNetworking.h>

#import "TSGamePlayHistory.h"
#import "AppDelegate.h"
#import "MUserInfo.h"
#import "RestManager.h"

@implementation TSGameServiceCalls

+ (TSGameServiceCalls *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static TSGameServiceCalls *instance = nil;
    dispatch_once(&token, ^{
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);  // XXX-TEST
        instance = [[TSGameServiceCalls alloc] init];
    });
    return instance;
}

- (void)fetchConfiguration:(__weak id<RestManagerResponseHandler>)handler {
    NSString *servicePath = [NSString stringWithFormat:@"/configurations/"];
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED");
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"responseObject": responseObject}];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"failed: %@; ERROR: %@", [operation request], error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}

- (void)fetchGameList:(__weak id<RestManagerResponseHandler>)handler {
    NSString *servicePath = [NSString stringWithFormat:@"/games/"];
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED");
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"responseObject": responseObject}];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"failed: %@; ERROR: %@", [operation request], error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}

- (void)fetchGameHistories:(__weak id<RestManagerResponseHandler>)handler {
    NSString *servicePath = [NSString stringWithFormat:@"/gamehistories/"];
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED");
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"responseObject": responseObject}];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"failed: %@; ERROR: %@", [operation request], error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}

- (void)postGameStart:(__weak id<RestManagerResponseHandler>)handler game:(TSGame *)game {
    NSManagedObjectContext *mainContext = [AppDelegate sharedAppDelegate].managedObjectContext;
    MUserInfo *currentUser = [MUserInfo currentAppUserInfoInContext:mainContext];
    
    TSGamePlayHistory *history = [[TSGamePlayHistory alloc] init];
    history.historyId = nil;
    history.gameId = game.gameId;
    history.userId = currentUser.appID;
    history.playedDate = [NSDate date];
    
    NSString *servicePath = [NSString stringWithFormat:@"/gamehistories/"];
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[TSGamePlayHistory gamePlayHistoryRequestMapping] objectClass:[TSGamePlayHistory class] rootKeyPath:nil method:RKRequestMethodPOST];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:history requestDescriptor:serialization error:&error] mutableCopy];
    [jsonDict removeObjectForKey:@"Result"];
    
    RKDotNetDateFormatter *dateFormatter = [[RestManager sharedInstance] defaultDotNetDateFormatter];
    jsonDict[@"PlayedDateTime"] = [dateFormatter stringFromDate:history.playedDate];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    request.HTTPMethod = @"POST";
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED");
        if (responseObject) {
            NSError *error = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
            if (!jsonDict) {
                DDLogCDebug(@"Error parsing JSON: %@", error);
            } else {
                TSGamePlayHistory *history = [[TSGamePlayHistory alloc] init];
                RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:jsonDict destinationObject:history mapping:[TSGamePlayHistory gamePlayHistoryResponseMapping]];
                NSError *error = nil;
                [mappingOperation performMapping:&error];
                if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
                    [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"gameHistory": history}];
                }
            }
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"failed: %@; ERROR: %@", [operation request], error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}

- (void)updateGameResult:(__weak id<RestManagerResponseHandler>)handler gameHistory:(TSGamePlayHistory *)gameHistory {
    NSString *servicePath = [NSString stringWithFormat:@"/gamehistories/%@", gameHistory.gameId];
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    request.HTTPMethod = @"PUT";
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    RKRequestDescriptor *serialization = [RKRequestDescriptor requestDescriptorWithMapping:[TSGamePlayHistory updateGamePlayHistoryRequestMapping] objectClass:[TSGamePlayHistory class] rootKeyPath:nil method:RKRequestMethodPOST];
    NSError *error = nil;
    NSMutableDictionary *jsonDict = [[RKObjectParameterization parametersWithObject:gameHistory requestDescriptor:serialization error:&error] mutableCopy];
    request.HTTPBody = [RKMIMETypeSerialization dataFromObject:jsonDict MIMEType:RKMIMETypeJSON error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED");
        if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
            [handler restManagerService:_cmd succeededWithOperation:operation userInfo:@{@"responseObject": responseObject}];
        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"failed: %@; ERROR: %@", [operation request], error);
        if ([handler respondsToSelector:@selector(restManagerService:failedWithOperation:error:userInfo:)]) {
            [handler restManagerService:_cmd failedWithOperation:operation error:error userInfo:nil];
        }
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}

#pragma mark - DEBUG
//XXX-ML Debug purpose
- (void)removeAllGameHistories {
    NSString *servicePath = @"";
    NSURL *serviceURL = [NSURL URLWithString:[appAPIBaseURLString stringByAppendingPathComponent:servicePath]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:serviceURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [request addValue:[RestManager sharedInstance].appToken forHTTPHeaderField:@"Authorization"];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject){
        DDLogCDebug(@"SUCCEED removed all game histories");
    }failure:^(AFHTTPRequestOperation *operation, NSError *error){
        DDLogCDebug(@"FAILED to remove all game histories: %@; ERROR: %@", [operation request], error);
    }];
    DDLogCDebug(@"%@", request);
    [operation start];
}
//XXX-ML

@end
