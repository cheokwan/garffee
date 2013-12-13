//
//  PhotoHuntGridButton.m
//  ToSavour
//
//  Created by LAU Leung Yan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "PhotoHuntGridButton.h"

#import <UIView+Helpers.h>
#import "PhotoHuntManager.h"

@interface PhotoHuntGridButton ()
@property (nonatomic, strong) UIView *foundView;
@end

@implementation PhotoHuntGridButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.changeGroup = CHANGE_GROUP_NONE;
    }
    return self;
}

- (void)buttonPressed:(id)sender {
    NSLog(@"button pressed");
    if ([_delegate respondsToSelector:@selector(photoHuntGridButton:didPressedWithChangeGroup:)]) {
        [_delegate photoHuntGridButton:self didPressedWithChangeGroup:_changeGroup];
    }
}

- (void)setIsFound:(BOOL)isFound {
    _isFound = isFound;
    if (_isFound) {
        if (!_foundView) {
            self.foundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frameSizeWidth, self.frameSizeHeight)];
            _foundView.backgroundColor = [UIColor greenColor];
            _foundView.alpha = 0.4f;
            [self addSubview:_foundView];
        }
    }
}

@end
