//
//  TutorialPageView.m
//  ToSavour
//
//  Created by Jason Wan on 10/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import "TutorialPageView.h"
#import "TSFrontEndIncludes.h"

@implementation TutorialPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initializeView {
    _bottomBackgroundView.backgroundColor = [[TSTheming defaultThemeColor] colorWithAlphaComponent:0.7];
    _brandNameView.image = [UIImage imageNamed:@"splash_garffee"];
    _descriptionLabel1.textColor = [TSTheming defaultAccentColor];
    _descriptionLabel1.backgroundColor = [UIColor clearColor];
    _descriptionLabel2.textColor = [TSTheming defaultAccentColor];
    _descriptionLabel2.backgroundColor = [UIColor clearColor];
    
    _anchorPhoneImageView.image = [UIImage imageNamed:@"splash_iphone"];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"splash_bg"];
    CGFloat imageRatio = backgroundImage.size.height / backgroundImage.size.width;
    CGRect imageFrame = CGRectMake(0, 0, _backgroundScrollView.bounds.size.height / imageRatio, _backgroundScrollView.bounds.size.height);
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    backgroundImageView.image = backgroundImage;
    [_backgroundScrollView addSubview:backgroundImageView];
    _backgroundScrollView .contentSize = CGSizeMake(backgroundImageView.bounds.size.width, backgroundImageView.bounds.size.height);
    _backgroundScrollView.bounces = NO;
    _backgroundScrollView.userInteractionEnabled = NO;  // delegate the scrolling to control scroll view
    _backgroundScrollView.scrollEnabled = NO;
    
    _screenshotScrollView.bounces = NO;
    _screenshotScrollView.userInteractionEnabled = NO;
    _screenshotScrollView.scrollEnabled = NO;
    
    _bottomBackgroundView.userInteractionEnabled = NO;
    
    _backgroundScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _screenshotScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _controlScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    NSArray *screenshots = @[[UIImage imageNamed:@"splash_phone_screen_1"],
                             [UIImage imageNamed:@"splash_phone_screen_2"],
                             [UIImage imageNamed:@"splash_phone_screen_3"],
                             [UIImage imageNamed:@"splash_phone_screen_4"],
                             [UIImage imageNamed:@"splash_phone_screen_5"]];
    CGFloat offsetX = 0.0;
    for (UIImage *image in screenshots) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, 0, _screenshotScrollView.bounds.size.width, _screenshotScrollView.bounds.size.height)];
        [imageView setBackgroundColor:[UIColor blackColor]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.image = image;
        [_screenshotScrollView addSubview:imageView];
        offsetX += _screenshotScrollView.bounds.size.width;
    }
    _screenshotScrollView.contentSize = CGSizeMake(offsetX, _screenshotScrollView.bounds.size.height);
    
    _controlScrollView.contentSize = CGSizeMake(_controlScrollView.bounds.size.width * TutorialPageViewPageTotal, _controlScrollView.bounds.size.height);
    _controlScrollView.backgroundColor = [UIColor clearColor];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeView];
}

- (CGFloat)controlForegroundScrollRatio {
//    return (_controlScrollView.contentSize.width - _controlScrollView.bounds.size.width) / (_screenshotScrollView.contentSize.width - _screenshotScrollView.bounds.size.width);
    return (_controlScrollView.contentSize.width - _controlScrollView.bounds.size.width) / (_screenshotScrollView.contentSize.width);
}

- (CGFloat)controlBackgroundScrollRatio {
    return (_controlScrollView.contentSize.width - _controlScrollView.bounds.size.width) / (_backgroundScrollView.contentSize.width - _backgroundScrollView.bounds.size.width);
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
