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

+ (NSString *)stringWithPrice:(CGFloat)price showFree:(BOOL)showFree {
    static NSString *priceFormatString = @"HK: $%.1f";
    return price == 0.0 && showFree ? LS_FREE : [NSString stringWithFormat:priceFormatString, price];
}

+ (NSString *)stringWithPrice:(CGFloat)price {
    return [self stringWithPrice:price showFree:NO];
}

- (NSArray *)decodeCommaSeparatedString {
    static NSString *delimiter = @", ";
    return [self componentsSeparatedByString:delimiter];
}

- (BOOL)isCaseInsensitiveEqual:(NSString *)other {
    return [[[self lowercaseString] trimmedWhiteSpaces] isEqualToString:[[other lowercaseString] trimmedWhiteSpaces]];
}

- (NSString *)canonicalPhoneNumber {
    // just strip out the unwanted characters for now
    static NSCharacterSet *rejectSet = nil;
    if (!rejectSet) {
        rejectSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet];
    }
    return [[self componentsSeparatedByCharactersInSet:rejectSet] componentsJoinedByString:@""];
}

@end
