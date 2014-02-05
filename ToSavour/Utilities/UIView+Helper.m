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

- (UIView *)subviewAtOrigin:(CGPoint)origin {
    for (UIView *subview in self.subviews) {
        if ((int)subview.frame.origin.x == (int)origin.x &&
            (int)subview.frame.origin.y == (int)origin.y) {
            return subview;
        }
    }
    return nil;
}

- (CGFloat)frameRight {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setFrameRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - self.frame.size.width;
    self.frame = frame;
}

- (CGFloat)frameBottom {
    return self.frame.origin.y + self.frame.size.height;
}

@end
