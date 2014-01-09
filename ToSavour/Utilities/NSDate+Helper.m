//
//  NSDate+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 8/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

+ (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *defaultDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultDateFormatter = [[NSDateFormatter alloc] init];
        [defaultDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return defaultDateFormatter;
}

- (NSString *)defaultStringRepresentation {
    return [[self.class defaultDateFormatter] stringFromDate:self];
}

@end
