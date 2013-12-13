//
//  PhotoHuntGridButton.m
//  ToSavour
//
//  Created by LAU Leung Yan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntGridButton.h"

#import "PhotoHuntViewController.h"

@implementation PhotoHuntGridButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.changeGroup = CHANGE_GROUP_NONE;
        self.backgroundColor = [UIColor blackColor];
        self.alpha = (float)rand() / RAND_MAX;
    }
    return self;
}

- (void)buttonPressed:(id)sender {
    NSLog(@"button pressed");
    if ([_delegate respondsToSelector:@selector(photoHuntGridButton:didPressedWithChangeGroup:)]) {
        [_delegate photoHuntGridButton:self didPressedWithChangeGroup:_changeGroup];
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
