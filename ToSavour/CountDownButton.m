//
//  CountDownButton.m
//  ToSavour
//
//  Created by LAU Leung Yan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "CountDownButton.h"
#import <UIView+Helpers.h>

@implementation CountDownButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect borderRect = CGRectMake(0.0, 0.0, self.frameSizeWidth, self.frameSizeHeight);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
//    CGContextSetLineWidth(context, 2.0);
    CGContextFillEllipseInRect (context, borderRect);
//    CGContextStrokeEllipseInRect(context, borderRect);
    CGContextFillPath(context);
}


@end
