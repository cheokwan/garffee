//
//  UIView+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 10/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView (Helper)

- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

@end
