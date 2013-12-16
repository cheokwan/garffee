//
//  TutorialLoginViewController.h
//  ToSavour
//
//  Created by Jason Wan on 9/12/13.
//  Copyright (c) 2013 NBition. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface TutorialLoginViewController : UIViewController<UIScrollViewDelegate, FBLoginViewDelegate>

@property (nonatomic, strong)   IBOutlet UIScrollView *tutorialScrollView;
@property (nonatomic, strong)   IBOutlet UIPageControl *tutorialPageControl;
@property (nonatomic, strong)   IBOutlet UIButton *skipButton;
@property (nonatomic, strong)   UIView *loginView;
@property (nonatomic, strong)   NSArray *tutorialImageViews;

@end
