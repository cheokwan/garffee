//
//  ItemGridView.m
//  ToSavour
//
//  Created by Jason Wan on 27/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import "ItemGridView.h"
#import "TSFrontEndIncludes.h"

@interface ItemGridView()
@property (nonatomic, strong) UIImageView *suggestedTag;
@end

@implementation ItemGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame text:(NSString *)text imageURL:(NSURL *)imageURL interactable:(BOOL)interactable shouldReceiveNotification:(BOOL)shouldReceiveNotification {
    self = [super initWithFrame:frame];
    self.userInteractionEnabled = YES;
    self.contentMode = UIViewContentModeCenter;
    self.backgroundColor = [UIColor clearColor];
    
    if (text) {
        self.textLabel = [self gridLabelWithText:text];
    }
    if (imageURL) {
        self.imageView = [self gridImageWithURL:imageURL];
    }
    if (interactable) {
        self.button = [self gridButton];
    }
    if (_button) {
        [self addSubview:_button];
    }
    if (_textLabel) {
        [self addSubview:_textLabel];
    }
    if (_imageView) {
        [self addSubview:_imageView];
        _textLabel.alpha = 0.0f;
    }
    if (shouldReceiveNotification) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:ItemGridViewDragTransitionNotificationStart object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:ItemGridViewDragTransitionNotificationStop object:nil];
    }
    return self;
}

- (void)setIsSuggested:(BOOL)isSuggested {
    _isSuggested = isSuggested;
    if (_isSuggested) {
        [self.imageView addSubview:self.suggestedTag];
    } else {
        [self.suggestedTag removeFromSuperview];
    }
}

- (UILabel *)gridLabelWithText:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.frame.size.width - 20.0, self.frame.size.height)];
    label.userInteractionEnabled = NO;
    label.contentMode = UIViewContentModeBottom;
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 3;
    label.font = [UIFont systemFontOfSize:10.0];
    label.textColor = [TSTheming defaultAccentColor];
    label.text = text;
    return label;
}

- (UIImageView *)gridImageWithURL:(NSURL *)url {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, self.frame.size.width - 20.0, self.frame.size.height - 20.0)];
    imageView.userInteractionEnabled = NO;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    __weak UIImageView *weakImageView = imageView;
    // TODO: set placeholder
    [imageView setImageWithURL:url placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (image) {
            // set the image to be larger so it is still clear when it is scaled up
            CGSize scaleUpSize = CGSizeMake(weakImageView.frame.size.width * 1.5, weakImageView.frame.size.height * 1.5);
            weakImageView.image = [image resizedImageToSize:scaleUpSize];
        } else {
            DDLogWarn(@"cannot set image for item grid: %@ - error %@", _textLabel.text, error);
        }
    }];
    return imageView;
}

- (UIButton *)gridButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10.0, 10.0, self.frame.size.width - 20.0, self.frame.size.height - 20.0);
    [button setBackgroundColor:[UIColor clearColor]];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIImageView *)suggestedTag {
    if (!_suggestedTag) {
        self.suggestedTag = [[UIImageView alloc] initWithFrame:CGRectMake(self.imageView.frame.size.width * 3.0 / 5.0, self.imageView.frame.size.height * 3.0 / 5.0, self.imageView.frame.size.width * 1.0 / 3.5, self.imageView.frame.size.height * 1.0 / 3.5)];
        _suggestedTag.image = [UIImage imageNamed:@"ico_garffee"];
    }
    return _suggestedTag;
}

- (void)buttonPressed:(id)sender {
    if (sender == _button) {
        if ([_delegate respondsToSelector:@selector(itemGridViewButtonDidPressed:)]) {
            [_delegate itemGridViewButtonDidPressed:self];
        }
    }
}

- (void)notificationReceived:(NSNotification *)notification {
    if ([notification.name isEqualToString:ItemGridViewDragTransitionNotificationStart]) {
        [UIView animateWithDuration:0.5 animations:^{
            _textLabel.alpha = 1.0;
            _imageView.alpha = 0.3;
        }];
    } else if ([notification.name isEqualToString:ItemGridViewDragTransitionNotificationStop]) {
        [UIView animateWithDuration:0.5 animations:^{
            _imageView.alpha = 1.0;
            _textLabel.alpha = 0.0;
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
