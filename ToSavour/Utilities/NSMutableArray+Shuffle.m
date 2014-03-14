//
//  NSMutableArray+Shuffle.m
//  ToSavour
//
//  Created by LAU Leung Yan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

- (void)shuffle {
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger n = arc4random_uniform((int)(count - i)) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end
