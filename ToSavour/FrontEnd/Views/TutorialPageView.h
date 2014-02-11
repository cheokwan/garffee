//
//  TutorialPageView.h
//  ToSavour
//
//  Created by Jason Wan on 10/2/14.
//  Copyright (c) 2014 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TutorialPageViewPageHome = 0,
    TutorialPageViewPageOrder,
    TutorialPageViewPageCart,
    TutorialPageViewPageStore,
    TutorialPageViewPageFriends,
    TutorialPageViewPageLogin,
    TutorialPageViewPageTotal,
} TutorialPageViewPage;

@interface TutorialPageView : UIView

@property (nonatomic, strong)   IBOutlet UIScrollView *backgroundScrollView;
@property (nonatomic, strong)   IBOutlet UIImageView *anchorPhoneImageView;
@property (nonatomic, strong)   IBOutlet UIScrollView *screenshotScrollView;
@property (nonatomic, strong)   IBOutlet UIView *bottomBackgroundView;
@property (nonatomic, strong)   IBOutlet UIImageView *brandNameView;
@property (nonatomic, strong)   IBOutlet UILabel *descriptionLabel1;
@property (nonatomic, strong)   IBOutlet UILabel *descriptionLabel2;
@property (nonatomic, strong)   IBOutlet UIScrollView *controlScrollView;

- (CGFloat)controlForegroundScrollRatio;

- (CGFloat)controlBackgroundScrollRatio;

@end
