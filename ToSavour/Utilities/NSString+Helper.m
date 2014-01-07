//
//  NSString+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)trimmedWhiteSpaces {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL)isEmpty {
    return [self trimmedWhiteSpaces].length == 0;
}

+ (NSString *)stringWithPrice:(CGFloat)price {
    static NSString *priceFormatString = @"HK: $%.1f";
    return [NSString stringWithFormat:priceFormatString, price];
}

- (NSArray *)decodeCommaSeparatedString {
    static NSString *delimiter = @", ";
    return [self componentsSeparatedByString:delimiter];
}

- (BOOL)isCaseInsensitiveEqual:(NSString *)other {
    return [[[self lowercaseString] trimmedWhiteSpaces] isEqualToString:[[other lowercaseString] trimmedWhiteSpaces]];
}

@end
