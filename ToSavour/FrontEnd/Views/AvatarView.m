//
//  AvatarView.m
//  ToSavour
//
//  Created by Jason Wan on 13/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "AvatarView.h"
#import "TSFrontEndIncludes.h"
#import <QuartzCore/QuartzCore.h>

@implementation AvatarView

- (void)initialize {
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_avatarButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_accessoryButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.isInteractable = YES;
    self.clipsToBounds = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    // force the frame to a square
    CGFloat minSide = MIN(frame.size.width, frame.size.height);
    frame = CGRectMake(frame.origin.x, frame.origin.y, minSide, minSide);
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame avatarImageURL:(NSURL *)avatarImageURL accessoryImageURL:(NSURL *)accessoryImageURL {
    self = [self initWithFrame:frame];
    if (self) {
        self.avatarImageURL = avatarImageURL;
        self.accessoryImageURL = accessoryImageURL;
        [self initializeView];  // TODO: generalize to other init methods
    }
    return self;
}

- (void)setIsInteractable:(BOOL)isInteractable {
    _isInteractable = isInteractable;
    _avatarButton.enabled = _isInteractable;
    _avatarButton.userInteractionEnabled = _isInteractable;
    _accessoryButton.enabled = _isInteractable;
    _accessoryButton.userInteractionEnabled = _isInteractable;
}

- (void)buttonPressed:(id)sender {
    if (sender == _avatarButton) {
        if ([_delegate respondsToSelector:@selector(avatarButtonPressedInAvatarView:)]) {
            [_delegate avatarButtonPressedInAvatarView:self];
        }
    } else if (sender == _accessoryButton) {
        if ([_delegate respondsToSelector:@selector(accessoryButtonPressedInAvatarView:)]) {
            [_delegate accessoryButtonPressedInAvatarView:self];
        }
    }
}

- (void)initializeView {
    // add the avatar button and image
    _avatarButton.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    // add the accessory button and image
    _accessoryButton.frame = CGRectMake(0, 0, _avatarButton.frame.size.width / 2.5, _avatarButton.frame.size.height / 2.5);
    CGFloat avatarButtonRadius = _avatarButton.frame.size.height / 2.0;
    CGFloat accessoryButtonOffset = avatarButtonRadius * cos(0.785398163);  // 45 degrees in radians
    _accessoryButton.center = CGPointMake(_avatarButton.center.x + accessoryButtonOffset, _avatarButton.center.y + accessoryButtonOffset);
    
    _avatarButton.imageView.layer.cornerRadius = _avatarButton.frame.size.height / 2.0;
    _accessoryButton.imageView.layer.cornerRadius = _accessoryButton.frame.size.height / 2.0;
    
    __weak UIButton *weakAvatarButton = _avatarButton;
    __weak NSURL *weakAvatarImageURL = _avatarImageURL;
    [_avatarButton.imageView setImageWithURL:_avatarImageURL placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image && !error) {
            [weakAvatarButton setImage:image forState:UIControlStateNormal];
        } else if (error) {
            DDLogWarn(@"error setting avatar image %@: %@", weakAvatarImageURL, error);
        }
    }];
    __weak UIButton *weakAccessoryButton = _accessoryButton;
    __weak NSURL *weakAccessoryImageURL = _accessoryImageURL;
    [_accessoryButton.imageView setImageWithURL:_accessoryImageURL placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image && !error) {
            [weakAccessoryButton setImage:image forState:UIControlStateNormal];
        } else if (error) {
            DDLogWarn(@"error setting accessory image %@: %@", weakAccessoryImageURL, error);
        }
    }];
    
    [self addSubview:_avatarButton];
    [self addSubview:_accessoryButton];
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
