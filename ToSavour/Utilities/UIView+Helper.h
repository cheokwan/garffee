//
//  UIView+Helper.h
//  ToSavour
//
//  Created by Jason Wan on 10/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Helper)

- (void)removeAllSubviews;
- (UIView *)subviewAtOrigin:(CGPoint)origin;

- (void)setFrameRight:(CGFloat)right;
- (CGFloat)frameRight;
- (CGFloat)frameBottom;

@end
