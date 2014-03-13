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
        instance = [[TSBranchServiceCalls alloc] init];
    });
    return instance;
}

- (void)fetchEstimatedTime:(__weak id<RestManagerResponseHandler>)handler branch:(MBranch *)branch {
    // XXX-STUB: stub for branch estimated time network call, TODO: replace with real call
    int estimatedTimeInMin = 10;
    if ([handler respondsToSelector:@selector(restManagerService:succeededWithOperation:userInfo:)]) {
        [handler restManagerService:_cmd succeededWithOperation:nil userInfo:@{@"EstimatedTime": [NSString stringWithFormat:@"%d", estimatedTimeInMin]}];
    }
}

@end
