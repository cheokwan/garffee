//
//  TutorialPageView.h
//  ToSavour
//
//  Created by Jason Wan on 10/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageView : UIView

@property (nonatomic, strong)   IBOutlet UIScrollView *backgroundScrollView;
@property (nonatomic, strong)   IBOutlet UIImageView *anchorPhoneImageView;
@property (nonatomic, strong)   IBOutlet UIScrollView *screenshotScrollView;
@property (nonatomic, strong)   IBOutlet UIView *bottomBackgroundView;
@property (nonatomic, strong)   IBOutlet UIImageView *brandNameView;
@property (nonatomic, strong)   IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong)   IBOutlet UIScrollView *controlScrollView;

- (CGFloat)controlForegroundScrollRatio;

- (CGFloat)controlBackgroundScrollRatio;

@end
