//
//  TSBranchServiceCalls.m
//  ToSavour
//
//  Created by LAU Leung Yan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "TSBranchServiceCalls.h"

@implementation TSBranchServiceCalls

+ (TSBranchServiceCalls *)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static TSBranchServiceCalls *instance = nil;
    dispatch_once(&token, ^{
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);  // XXX-TEST
        instance = [[TSBranchServiceCalls alloc] init];
    });
    return instance;
}

- (void)fetchEstimatedTime:(__weak id<RestManagerResponseHandler>)handler branch:(MBranch *)branch {
    //XXX-ML TO-DO: network call
    int randomMin = arc4random() % 30 + 5;
    if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
        [handler restManagerService:_cmd succeededWithOperation:nil userInfo:@{@"EstimatedTime": [NSString stringWithFormat:@"%d", randomMin]}];
    }
}

@end
