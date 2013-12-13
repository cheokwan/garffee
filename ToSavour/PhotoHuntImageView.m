//
//  PhotoHuntImageView.m
//  ToSavour
//
//  Created by LAU Leung Yan on 14/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntImageView.h"

#import <UIView+Helpers.h>

#import "PhotoHuntViewController.h"

@interface PhotoHuntImageView ()
@property (nonatomic, strong) UIView *touchWrongView;
@property (nonatomic) BOOL isAnimating;
@end

@implementation PhotoHuntImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (!_touchWrongView) {
        self.touchWrongView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GRID_WIDTH, GRID_HEIGHT)];
    }
    if (!_isAnimating) {
        _isAnimating = YES;
        UITouch *tapTouch = nil;
        for (UITouch *touch in touches) {
            if (touch.phase == UITouchPhaseEnded) {
                tapTouch = touch;
                break;
            }
        }
        if (tapTouch) {
            CGPoint touchedPosition = [tapTouch locationInView:self];
            float xPos = (floorf(touchedPosition.x/GRID_WIDTH)) * GRID_WIDTH;
            float yPos = (floorf(touchedPosition.y/GRID_HEIGHT)) * GRID_HEIGHT;
            [_touchWrongView setFrameOrigin:CGPointMake(xPos, yPos)];
            _touchWrongView.backgroundColor = [UIColor redColor];
            _touchWrongView.alpha = 0.0f;
            if (!_touchWrongView.superview) {
                [self addSubview:_touchWrongView];
            }
            [UIView animateWithDuration:PRESS_WRONG_RED_FLASH_DURATION animations:^{
                _touchWrongView.alpha = 0.7f;
                _touchWrongView.alpha = 0.0f;
            }completion:^(BOOL finished){
                _isAnimating = NO;
            }];
        } else {
            _isAnimating = NO;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
