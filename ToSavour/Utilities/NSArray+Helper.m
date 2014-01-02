//
//  NSArray+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 2/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "NSArray+Helper.h"

@implementation NSArray (Helper)

- (NSString *)commaSeparatedString {
    if (self.count == 0 || ![self[0] isKindOfClass:NSString.class]) {
        return nil;
    }
    static NSString *delimiter = @", ";
    NSMutableString *string = [self[0] mutableCopy];
    for (int i = 1; i < self.count; ++i) {
        if ([self[i] isKindOfClass:NSString.class]) {
            [string appendString:delimiter];
            [string appendString:self[i]];
        }
    }
    return string;
}

@end
