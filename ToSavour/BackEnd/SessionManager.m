//
//  SessionManager.m
//  ToSavour
//
//  Created by Jason Wan on 13/3/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t token = 0;
    __strong static id instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
