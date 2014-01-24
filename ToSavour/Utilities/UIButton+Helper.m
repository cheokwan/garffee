//
//  UIButton+Helper.m
//  ToSavour
//
//  Created by Jason Wan on 24/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "UIButton+Helper.h"

@implementation UIButton (Helper)

- (void)unhideEnable:(BOOL)animated {
    self.enabled = YES;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1.0;
        }];
    } else {
        self.alpha = 1.0;
    }
}

- (void)hideDisable:(BOOL)animated {
    self.enabled = NO;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0.0;
        }];
    } else {
        self.alpha = 0.0;
    }
}

@end
