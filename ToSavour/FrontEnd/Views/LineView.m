//
//  LineView.m
//  ToSavour
//
//  Created by Jason Wan on 7/1/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "LineView.h"

@implementation LineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);  // default color
    
    CGContextSetLineWidth(context, 0.2);
    
    CGPoint start = CGPointMake(self.frame.origin.x, self.frame.size.height / 2.0);
    CGPoint end = CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.size.height / 2.0);
    
    CGContextMoveToPoint(context, start.x, start.y); //start at this point
    
    CGContextAddLineToPoint(context, end.x, end.y); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
