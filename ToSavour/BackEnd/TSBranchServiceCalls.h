//
//  TSBranchServiceCalls.h
//  ToSavour
//
//  Created by LAU Leung Yan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "RestManager.h"

#import "MBranch.h"

@interface TSBranchServiceCalls : RestManager

+ (TSBranchServiceCalls *)sharedInstance;

- (void)fetchEstimatedTime:(__weak id<RestManagerResponseHandler>)handler branch:(MBranch *)branch;

@end
