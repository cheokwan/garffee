//
//  NSString+Helper.h
//  ToSavour
//
//  Created by Jason Wan on 17/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (NSString *)trimmedWhiteSpaces;

- (BOOL)isEmpty;

+ (NSString *)stringWithPrice:(CGFloat)price;

- (NSArray *)decodeCommaSeparatedString;

- (BOOL)isCaseInsensitiveEqual:(NSString *)other;

- (NSString *)canonicalPhoneNumber;

@end
